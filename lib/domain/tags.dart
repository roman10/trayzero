import 'entities/entities.dart';

/// Tag naming and matching rules (ADR 0010). Pure, no I/O.

/// Longest tag name kept; longer input is cut so chips stay readable.
const maxTagNameLength = 40;

/// The display name to store for user input: trimmed, inner whitespace
/// collapsed, leading `+`, `#`, and `@` sigils removed, and capped at
/// [maxTagNameLength]. Null when nothing usable remains.
String? cleanTagName(String input) {
  var name = input
      .trim()
      .replaceFirst(RegExp(r'^[+#@\s]+'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (name.isEmpty) return null;
  if (name.runes.length > maxTagNameLength) {
    name = String.fromCharCodes(name.runes.take(maxTagNameLength)).trim();
  }
  return name;
}

/// Uniqueness key: tag names are unique ignoring case (Unicode lowercase)
/// after [cleanTagName]. Empty for unusable input.
String tagKey(String name) => (cleanTagName(name) ?? '').toLowerCase();

/// The tag in [tags] whose name equals [name] ignoring case, if any.
Tag? findTagByName(Iterable<Tag> tags, String name) {
  final key = tagKey(name);
  if (key.isEmpty) return null;
  for (final t in tags) {
    if (tagKey(t.name) == key) return t;
  }
  return null;
}

/// Alphabetical, ignoring case; the order of every tag list and chip row.
List<Tag> sortTags(Iterable<Tag> tags) => [...tags]
  ..sort((a, b) {
    final byKey = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return byKey != 0 ? byKey : a.id.compareTo(b.id);
  });

/// Whether a Waiting For `waitingOn` text names [person]: the person's name
/// appears in it as whole words, ignoring case ("Alice", "alice (legal)",
/// "Bob and Alice"), but "Alison" does not match "Ali".
bool waitingOnNamesPerson(String? waitingOn, String person) {
  if (waitingOn == null) return false;
  final needle = _words(person);
  final hay = _words(waitingOn);
  if (needle.isEmpty || needle.length > hay.length) return false;
  for (var i = 0; i + needle.length <= hay.length; i++) {
    var all = true;
    for (var j = 0; j < needle.length; j++) {
      if (hay[i + j] != needle[j]) {
        all = false;
        break;
      }
    }
    if (all) return true;
  }
  return false;
}

List<String> _words(String text) => RegExp(
  r'[\p{L}\p{N}]+',
  unicode: true,
).allMatches(text.toLowerCase()).map((m) => m.group(0)!).toList();

/// Statuses whose Items belong on a person's Agenda: the actionable lists.
/// Someday and Reference are not talking points; Done and Trash are history.
const agendaStatuses = {
  ItemStatus.inbox,
  ItemStatus.nextAction,
  ItemStatus.waiting,
  ItemStatus.calendar,
};

/// One person's Agenda (ADR 0010): open Items tagged with them, plus Waiting
/// For Items whose `waitingOn` names them and that are not tagged.
class Agenda {
  const Agenda({
    required this.person,
    required this.tagged,
    required this.waitingOn,
  });

  final Tag person;
  final List<Item> tagged;
  final List<Item> waitingOn;

  int get count => tagged.length + waitingOn.length;
}

/// Agendas for every person tag in [tags], alphabetical. [items] are the
/// open Items (any order is kept); [itemTags] maps Item id to tag ids.
List<Agenda> buildAgendas({
  required List<Tag> tags,
  required List<Item> items,
  required Map<String, List<String>> itemTags,
}) {
  final open = [
    for (final i in items)
      if (i.completedAt == null && agendaStatuses.contains(i.status)) i,
  ];
  return [
    for (final person in sortTags(tags.where((t) => t.isPerson)))
      () {
        final tagged = <Item>[];
        final waiting = <Item>[];
        for (final i in open) {
          if (itemTags[i.id]?.contains(person.id) ?? false) {
            tagged.add(i);
          } else if (i.status == ItemStatus.waiting &&
              waitingOnNamesPerson(i.waitingOn, person.name)) {
            waiting.add(i);
          }
        }
        return Agenda(person: person, tagged: tagged, waitingOn: waiting);
      }(),
  ];
}

/// How restored backup tags land among [local] ones (ADR 0010): [upserts] to
/// write, and [idMap] from each backup id to the id Items should link to.
/// A backup tag whose id exists locally is updated in place; one whose name
/// matches a *different* tag (ignoring case) is merged onto that tag, so a
/// restore never creates two tags with the same name. A merge keeps the
/// person flag when either side has it.
///
/// Name ownership is decided against the names tags hold *after* the
/// restore, not before: in-place renames are settled first, so a backup that
/// renamed "Home" to "Work" and then created a new "Home" (or swapped two
/// names) frees and reuses names instead of merging the wrong tags. Only a
/// rename onto a name still held by a local tag the backup doesn't mention
/// (or by an earlier backup tag) fails; that tag keeps its local row and
/// merges onto the holder.
({List<Tag> upserts, Map<String, String> idMap}) planTagRestore(
  List<Tag> backup,
  List<Tag> local,
) {
  final localById = {for (final t in local) t.id: t};
  final backupIds = {for (final b in backup) b.id};
  // Local tags the backup leaves alone keep their names no matter what.
  final fixed = [
    for (final t in local)
      if (!backupIds.contains(t.id)) t,
  ];
  final renames = [
    for (final b in backup)
      if (localById.containsKey(b.id)) b,
  ];
  // Settle renames to a fixed point: a rename whose name is taken fails and
  // its tag stays put under its local name, which may in turn block another
  // rename. Each pass fixes one more tag, so this terminates.
  late Map<String, String> owners;
  while (true) {
    owners = {for (final t in fixed) tagKey(t.name): t.id};
    Tag? blocked;
    for (final r in renames) {
      final key = tagKey(r.name);
      if (owners.containsKey(key)) {
        blocked = r;
        break;
      }
      owners[key] = r.id;
    }
    if (blocked == null) break;
    renames.remove(blocked);
    fixed.add(localById[blocked.id]!);
  }

  final idMap = <String, String>{};
  final upserts = <String, Tag>{};
  for (final r in renames) {
    upserts[r.id] = r;
    idMap[r.id] = r.id;
  }
  for (final b in backup) {
    if (idMap.containsKey(b.id)) continue;
    final key = tagKey(b.name);
    final owner = owners[key];
    if (owner == null) {
      // A new tag (renames are all settled, so only new ids get here).
      owners[key] = b.id;
      upserts[b.id] = b;
      idMap[b.id] = b.id;
      continue;
    }
    idMap[b.id] = owner;
    final target = upserts[owner] ?? localById[owner]!;
    if (b.isPerson && !target.isPerson) {
      upserts[owner] = target.copyWith(isPerson: true);
    }
  }
  return (upserts: upserts.values.toList(), idMap: idMap);
}
