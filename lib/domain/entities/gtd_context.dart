/// A GTD context — a tag describing where or with what equipment an
/// action can be performed (e.g. `@phone`, `@computer`, `@errands`).
class GtdContext {
  const GtdContext({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String icon; // material icon code-point name
  final int color; // ARGB int
  final int sortOrder;

  GtdContext copyWith({
    String? name,
    String? icon,
    int? color,
    int? sortOrder,
  }) =>
      GtdContext(
        id: id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        sortOrder: sortOrder ?? this.sortOrder,
      );
}
