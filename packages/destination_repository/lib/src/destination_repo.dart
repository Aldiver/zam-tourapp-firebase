import 'package:destination_repository/destination_repository.dart';
import 'package:destination_repository/src/models/itinerary.dart';

abstract class DestinationRepo {
  Future<List<Destination>> getDestinations(String userId);
  Future<List<Itinerary>> getItineraries();
  //Future<List<Rating>> getRatings();

  Future<void> updateRating(
      String destinationId, double userRating, String userId);
}
