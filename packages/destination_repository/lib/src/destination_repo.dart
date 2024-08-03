import 'package:destination_repository/destination_repository.dart';

abstract class DestinationRepo {
  Future<List<Destination>> getDestinations(String userId);
  //Future<List<Menu>> getMenus();
  //Future<List<Rating>> getRatings();

  Future<void> updateRating(
      String destinationId, double userRating, String userId);
}
