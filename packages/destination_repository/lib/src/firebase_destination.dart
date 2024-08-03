import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destination_repository/destination_repository.dart';

class FirebaseDestinationRepo implements DestinationRepo {
  final destinationCollection =
      FirebaseFirestore.instance.collection('destinations');
  final ratingCollection = FirebaseFirestore.instance.collection('ratings');
  final menuCollection = FirebaseFirestore.instance.collection('menus');

  @override
  Future<List<Destination>> getDestinations(String userId) async {
    try {
      final destinationDocs = await destinationCollection.get();
      // final ratingDocs = await ratingCollection.get();
      final menuDocs = await menuCollection.get();

      final destinations = destinationDocs.docs
          .map((e) =>
              Destination.fromEntity(DestinationEntity.fromDocument(e.data())))
          .toList();

      // // Handle ratings
      // List<RatingEntity> ratings = [];
      // if (ratingDocs.docs.isNotEmpty) {
      //   ratings = ratingDocs.docs
      //       .map((e) => RatingEntity.fromDocument(e.data()))
      //       .toList();
      // }

      // Handle menus
      final menus =
          menuDocs.docs.map((e) => MenuEntity.fromDocument(e.data())).toList();

      // Map ratings and menus to their respective destinations
      for (var destination in destinations) {
        // final destinationRatings = ratings
        //     .where((rating) => rating.destinationId == destination.id)
        //     .toList();

        // if (destinationRatings.isNotEmpty) {
        //   destination.aveRating = destinationRatings
        //           .map((rating) => rating.rating)
        //           .reduce((a, b) => a + b) /
        //       destinationRatings.length;
        //   destination.rating = destinationRatings.length;
        // } else {
        //   destination.aveRating = 0;
        //   destination.rating = 0;
        // }

        // Assuming `userId` is available in your context to get `userRating`
        // final userRating = destinationRatings.firstWhere(
        //     (rating) => rating.userId == userId,
        //     orElse: () => RatingEntity.empty);
        // destination.userRating = userRating.rating;
        // destination.ratingId = userRating.id;
        // log("Updated Ratings Kimene ${destination.id} -> ${destination.userRating}");

        final matchedMenu = menus.firstWhere(
          (menu) => menu.destinationId == destination.id,
          orElse: () => MenuEntity.empty(),
        );

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
      String destinationId, double userRating, String userId) async {
    try {
      String ratingId = '${userId}_$destinationId';
      await ratingCollection.doc(ratingId).set({
        'userId': userId,
        'destinationId': destinationId,
        'rating': userRating,
      }, SetOptions(merge: true));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
