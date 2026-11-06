"""Reject successful instrumentation runs that omitted a required native check."""
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

results = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(
    "build/app/outputs/androidTest-results/connected/release"
)
expected = {
    "portable backup restores files and SQLite on a fresh store",
    "deleting an Item cleans its owned native calendar event",
    "diagnostics: build mode / permission / tz / exact alarms",
    "R8/Gson round-trip: schedule twice, then read back pending requests",
    "real delivery: a near-future reminder actually posts",
}
passed = set()
for report in results.glob("TEST-*.xml"):
    for case in ET.parse(report).getroot().iter("testcase"):
        if case.get("classname") == "app.cleartray.NativeReleaseTest":
            if any(case.find(tag) is not None for tag in ("skipped", "failure", "error")):
                raise SystemExit(f"Native check did not pass: {case.get('name')}")
            passed.add(case.get("name"))
missing = expected - passed
if missing:
    raise SystemExit("Missing successful native checks: " + ", ".join(sorted(missing)))
print(f"Verified all {len(expected)} required native release checks.")
