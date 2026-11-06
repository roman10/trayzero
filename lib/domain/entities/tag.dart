/// A free-form label an Item can carry, many per Item (ADR 0010). Separate
/// from the single GTD [GtdContext]. A tag marked [isPerson] is someone the
/// user talks to; it gets an Agenda.
class Tag {
  const Tag({required this.id, required this.name, this.isPerson = false});

  final String id;
  final String name;
  final bool isPerson;

  Tag copyWith({String? name, bool? isPerson}) =>
      Tag(id: id, name: name ?? this.name, isPerson: isPerson ?? this.isPerson);

  @override
  bool operator ==(Object other) =>
      other is Tag &&
      other.id == id &&
      other.name == name &&
      other.isPerson == isPerson;

  @override
  int get hashCode => Object.hash(id, name, isPerson);
}
