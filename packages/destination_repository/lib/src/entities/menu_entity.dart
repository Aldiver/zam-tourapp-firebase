class MenuEntity {
  final String id;
  final String destinationId;
  final List<Map<String, dynamic>> items;

  MenuEntity({
    required this.id,
    required this.destinationId,
    required this.items,
  });

  factory MenuEntity.empty() {
    return MenuEntity(
      id: '',
      destinationId: '',
      items: [],
    );
  }

  factory MenuEntity.fromDocument(Map<String, dynamic> doc) {
    return MenuEntity(
      id: doc['id'],
      destinationId: doc['destinationId'],
      items: List<Map<String, dynamic>>.from(doc['menuItem'] ?? []),
    );
  }
}
