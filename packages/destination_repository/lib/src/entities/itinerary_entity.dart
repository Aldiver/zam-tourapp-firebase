class ItineraryEntity {
  String id;
  String name;
  List<dynamic>? destinations;

  ItineraryEntity({
    required this.id,
    required this.name,
    required this.destinations,
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'name': name,
      'destinations': destinations,
    };
  }

  static ItineraryEntity fromDocument(
      Map<String, dynamic> document, String docId) {
    return ItineraryEntity(
      id: docId,
      name: document['name'],
      destinations: document['destinations'],
    );
  }
}
