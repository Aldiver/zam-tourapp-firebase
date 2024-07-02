import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:destination_repository/destination_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

part 'destination_event.dart';
part 'destination_state.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final FirebaseDestinationRepo _destinationRepository;

  DestinationBloc(this._destinationRepository) : super(DestinationInitial()) {
    on<FetchDestinations>((event, emit) async {
      emit(DestinationLoading());
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          emit(const DestinationError("Location services are disabled."));
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            emit(const DestinationError("Location permissions are denied."));
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          emit(const DestinationError(
              "Location permissions are permanently denied."));
          return;
        }

        final destinations = await _destinationRepository.getDestinations();
        // Filter destinations by tags
        final mountainDestinations = destinations
            .where((d) => d.tags?.contains("Mountain") ?? false)
            .toList();
        final beachDestinations = destinations
            .where((d) => d.tags?.contains("Beach") ?? false)
            .toList();
        final forestDestinations = destinations
            .where((d) => d.tags?.contains("Forest") ?? false)
            .toList();
        final cityDestinations = destinations
            .where((d) => d.tags?.contains("City") ?? false)
            .toList();
        final foodDestinations = destinations
            .where((d) => d.tags?.contains("Food") ?? false)
            .toList();
        final bedsDestinations = destinations
            .where((d) => d.tags?.contains("Beds") ?? false)
            .toList();

        // Randomly select 10 destinations for explore
        final exploreDestinations =
            (destinations.toList()..shuffle()).take(10).toList();

        // log('check this part ${exploreDestinations.first.menu!.first.price}');
        // Get user's current location for nearby destinations
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        //remmove
        await Future.forEach(destinations, (destination) async {
          double distanceInMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            destination.locationCoords.latitude,
            destination.locationCoords.longitude,
          );

          // Convert distance to km or m
          String distanceText = distanceInMeters < 1000
              ? '${distanceInMeters.toInt()}m'
              : '${(distanceInMeters / 1000).toStringAsFixed(1)}km';

          // Update the destination's distance property
          destination.distance = distanceText;
          // log("distance is: $distanceText");
        });

        // Fetch the address for the current location
        List<Placemark> placemarks =
            await placemarkFromCoordinates(52.2165157, 6.9437819);
        // List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        String locationAddress = placemarks.isNotEmpty
            ? '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}'
            : 'Unknown location';

        // String locationAddress = "Zamboanga";

        // Convert position to GeoPoint (adjust based on your implementation)
        GeoPoint location = GeoPoint(position.latitude, position.longitude);

        final nearbyDestinations = destinations
            .where((d) {
              double distanceInMeters = Geolocator.distanceBetween(
                  position.latitude,
                  position.longitude,
                  d.locationCoords.latitude,
                  d.locationCoords.longitude);
              return distanceInMeters < 20000; // Example: within 20 km
            })
            .take(10)
            .toList();
        
        emit(DestinationSuccess(
          destinations,
          exploreDestinations,
          nearbyDestinations,
          mountainDestinations,
          beachDestinations,
          forestDestinations,
          cityDestinations,
          foodDestinations,
          bedsDestinations,
          location,
          locationAddress,
        ));
      } catch (e) {
        log("Error fetching location: $e");
        emit(DestinationFailure());
      }
    });
  }
}
