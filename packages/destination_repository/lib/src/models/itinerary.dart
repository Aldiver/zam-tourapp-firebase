import '../entities/entities.dart';

class Itinerary {
  String id;
  String name;
  List<dynamic>? destinations;

  Itinerary({
    required this.id,
    required this.name,
    required this.destinations,
  });

  static final empty = Itinerary(
    id: '',
    name: '',
    destinations: [],
  );

  ItineraryEntity toEntity() {
    return ItineraryEntity(
      id: id,
      name: name,
      destinations: [],
    );
  }

  static Itinerary fromEntity(ItineraryEntity entity) {
    return Itinerary(
      id: entity.id,
      name: entity.name,
      destinations: entity.destinations,
    );
  }

  @override
  String toString() {
    return 'Itinerary{id: $id, name: $name, destinations: $destinations}';
  }
}
