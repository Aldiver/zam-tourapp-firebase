import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destination_repository/destination_repository.dart';
import 'package:destination_repository/src/entities/entities.dart';
import 'package:destination_repository/src/models/itinerary.dart';

class FirebaseDestinationRepo implements DestinationRepo {
  final destinationCollection =
      FirebaseFirestore.instance.collection('destinations');
  final ratingCollection = FirebaseFirestore.instance.collection('ratings');
  final menuCollection = FirebaseFirestore.instance.collection('menus');
  final itineraryCollection =
      FirebaseFirestore.instance.collection('itineraries');

  @override
  Future<List<Destination>> getDestinations(String userId) async {
    try {
      final destinationDocs = await destinationCollection.get();
      final ratingDocs = await ratingCollection.get();
      final menuDocs = await menuCollection.get();

      final destinations = destinationDocs.docs
          .map((e) =>
              Destination.fromEntity(DestinationEntity.fromDocument(e.data())))
          .toList();

      Map<String, RatingEntity> ratingsMap = {};
      if (ratingDocs.docs.isNotEmpty) {
        for (var doc in ratingDocs.docs) {
          final rating = RatingEntity.fromDocument(doc.data());
          final docId =
              '${rating.userId}_${rating.destinationId}'; // Create the key
          ratingsMap[docId] = rating;
        }
      }

      // Handle menus
      final menus =
          menuDocs.docs.map((e) => MenuEntity.fromDocument(e.data())).toList();

      // Map ratings and menus to their respective destinations
      for (var destination in destinations) {
        final ratingKey = '${userId}_${destination.id}';
        destination.userRating = ratingsMap[ratingKey]?.rating ?? 0.0;

        // Menus
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

  @override
  Future<List<Itinerary>> getItineraries() async {
    try {
      final itineraryDocs = await itineraryCollection.get();
      final itineraries = itineraryDocs.docs
          .map((e) => Itinerary.fromEntity(
              ItineraryEntity.fromDocument(e.data(), e.id)))
          .toList();
      return itineraries;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
