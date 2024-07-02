import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destination_repository/destination_repository.dart';

class FirebaseDestinationRepo implements DestinationRepo {
  final destinationCollection =
      FirebaseFirestore.instance.collection('destinations');
  final ratingCollection = FirebaseFirestore.instance.collection('ratings');
  final menuCollection = FirebaseFirestore.instance.collection('menus');

  @override
  Future<List<Destination>> getDestinations() async {
    try {
      final destinationDocs = await destinationCollection.get();
      final ratingDocs = await ratingCollection.get();
      final menuDocs = await menuCollection.get();

      final destinations = destinationDocs.docs
          .map((e) =>
              Destination.fromEntity(DestinationEntity.fromDocument(e.data())))
          .toList();

      // Handle ratings
      List<RatingEntity> ratings = [];
      if (ratingDocs.docs.isNotEmpty) {
        ratings = ratingDocs.docs
            .map((e) => RatingEntity.fromDocument(e.data()))
            .toList();
      }

      // Handle menus
      final menus =
          menuDocs.docs.map((e) => MenuEntity.fromDocument(e.data())).toList();

      // Map ratings and menus to their respective destinations
      for (var destination in destinations) {
        if (ratings.isNotEmpty) {
          destination.userRating = ratings
                  .where((rating) => rating.destinationId == destination.id)
                  .map((rating) => rating.rating)
                  .reduce((a, b) => a + b) /
              ratings
                  .where((rating) => rating.destinationId == destination.id)
                  .length;
        } else {
          destination.userRating = 0; // Set default userRating if no ratings
        }

        final matchedMenu = menus.firstWhere(
          (menu) => menu.destinationId == destination.id,
          orElse: () => MenuEntity.empty(),
        );

        // if (matchedMenu.id.isNotEmpty) {
        //   destination.menu = Menu.fromEntity(matchedMenu);
        // }

        destination.menu = Menu.fromEntity(matchedMenu);
      }

      return destinations;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateRating(
      Destination destination, double userRating, String userId) {
    // TODO: implement updateRating
    throw UnimplementedError();
  }
}
