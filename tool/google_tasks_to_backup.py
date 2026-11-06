#!/usr/bin/env python3
"""Convert a Google Takeout Tasks.json export into a Trayzero backup JSON.

Mapping (per user choice):
  - Every Google task -> one Inbox item (status: inbox). Lists are NOT
    turned into Projects/Contexts; the source list name is preserved in
    the item's notes instead.
  - Completed tasks are skipped.
  - Sub-tasks are flattened to their own Inbox items, with the parent
    task title recorded in notes.

Usage:
    python3 tool/google_tasks_to_backup.py Tasks.json > trayzero-from-gtasks.json

Then in the app: Settings -> Import backup -> paste the output JSON.
"""
import json
import sys
from datetime import datetime, timezone


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def norm_date(value):
    """Google uses RFC3339 (often with trailing Z). Return ISO-8601 or None."""
    if not value or not isinstance(value, str):
        return None
    try:
        # Python <3.11 doesn't parse a bare 'Z'; normalise it.
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
        return parsed.isoformat()
    except ValueError:
        return None


def due_date(value):
    """Google due encodes a calendar date, not a midnight-UTC instant.

    Emit local midnight without an offset so the importing device keeps the
    source day regardless of where this conversion script is run.
    """
    if not norm_date(value):
        return None
    try:
        return datetime.strptime(value[:10], "%Y-%m-%d").isoformat()
    except ValueError:
        return None


def build_notes(original_notes, list_name, parent_title):
    parts = []
    if original_notes:
        parts.append(original_notes.strip())
    meta = []
    if list_name:
        meta.append(f"List: {list_name}")
    if parent_title:
        meta.append(f"Subtask of: {parent_title}")
    if meta:
        parts.append(" · ".join(meta))
    return "\n\n".join(parts) if parts else None


def is_completed(task) -> bool:
    return task.get("status") == "completed" or bool(task.get("completed"))


def emit_task(task, list_name, parent_title, fallback_ts, out_items):
    if is_completed(task):
        # Still descend into sub-tasks: a done parent can have open children.
        for sub in task.get("subtasks", []) or []:
            emit_task(sub, list_name, task.get("title"), fallback_ts, out_items)
        return

    gid = task.get("id") or f"gt-{len(out_items)}"
    created = norm_date(task.get("created")) or fallback_ts
    updated = norm_date(task.get("updated")) or created

    out_items.append({
        "id": f"gt-{gid}",
        "title": (task.get("title") or "(untitled)").strip() or "(untitled)",
        "notes": build_notes(task.get("notes"), list_name, parent_title),
        "status": "inbox",
        "projectId": None,
        "contextId": None,
        "dueAt": due_date(task.get("due")),
        "deferUntil": None,
        "waitingOn": None,
        "energy": None,
        "timeEstimateMinutes": None,
        "isTwoMin": False,
        "createdAt": created,
        "updatedAt": updated,
        "completedAt": None,
        "sortOrder": len(out_items),
        "recurrence": None,
        "recurrenceInterval": 1,
    })

    for sub in task.get("subtasks", []) or []:
        emit_task(sub, list_name, task.get("title"), fallback_ts, out_items)


def main(argv):
    if len(argv) != 2:
        sys.stderr.write("usage: google_tasks_to_backup.py Tasks.json\n")
        return 2

    with open(argv[1], "r", encoding="utf-8") as fh:
        data = json.load(fh)

    fallback_ts = now_iso()
    items = []
    # Takeout shape: { "items": [ { "title": <list>, "items": [tasks] } ] }
    for task_list in data.get("items", []) or []:
        list_name = task_list.get("title")
        for task in task_list.get("items", []) or []:
            emit_task(task, list_name, None, fallback_ts, items)

    backup = {
        "version": 2,
        "exportedAt": fallback_ts,
        "contexts": [],
        "areas": [],
        "projects": [],
        "items": items,
    }
    json.dump(backup, sys.stdout, indent=2, ensure_ascii=False)
    sys.stdout.write("\n")
    sys.stderr.write(f"Converted {len(items)} open task(s) to Inbox items.\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
