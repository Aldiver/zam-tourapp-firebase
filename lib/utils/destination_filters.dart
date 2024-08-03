// utils/destination_filters.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:destination_repository/destination_repository.dart';

List<Destination> filterDestinationsByTag(
    List<Destination> destinations, String tag) {
  return destinations.where((d) => d.tags?.contains(tag) ?? false).toList();
}

List<Destination> getExploreDestinations(List<Destination> destinations) {
  return (destinations.toList()..shuffle()).take(10).toList();
}

List<Destination> getNearbyDestinations(
    List<Destination> destinations, GeoPoint location) {
  return destinations
      .where((d) {
        double distanceInMeters = Geolocator.distanceBetween(
          location.latitude,
          location.longitude,
          d.locationCoords.latitude,
          d.locationCoords.longitude,
        );
        return distanceInMeters < 20000; // Example: within 20 km
      })
      .take(10)
      .toList();
}
