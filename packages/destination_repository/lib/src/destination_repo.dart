import 'package:destination_repository/destination_repository.dart';

abstract class DestinationRepo {
    Future<List<Destination>> getDestinations();
    //Future<List<Menu>> getMenus();
    //Future<List<Rating>> getRatings();


    Future<void> updateRating(Destination destination, double userRating, String userId);
}