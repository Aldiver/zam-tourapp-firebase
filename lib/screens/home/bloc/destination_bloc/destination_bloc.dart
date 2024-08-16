import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:destination_repository/destination_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:zc_tour_app/blocs/authentication_bloc/authentication_bloc.dart';

part 'destination_event.dart';
part 'destination_state.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final FirebaseDestinationRepo _destinationRepository;
  final AuthenticationBloc _authenticationBloc;

  DestinationBloc(this._destinationRepository, this._authenticationBloc)
      : super(DestinationInitial()) {
    final user = _authenticationBloc.state.user;

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

        final destinations =
            await _destinationRepository.getDestinations(user!.userId);

        // Get user's current location for nearby destinations
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        // Update distances
        await Future.forEach(destinations, (destination) async {
          double distanceInMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            destination.locationCoords.latitude,
            destination.locationCoords.longitude,
          );

          String distanceText = distanceInMeters < 1000
              ? '${distanceInMeters.toInt()}m'
              : '${(distanceInMeters / 1000).toStringAsFixed(1)}km';

          destination.distance = distanceText;
        });

        // Fetch the address for the current location
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        String locationAddress = placemarks.isNotEmpty
            ? '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}'
            : 'Unknown location';

        GeoPoint location = GeoPoint(position.latitude, position.longitude);

        emit(DestinationSuccess(destinations, location, locationAddress));
      } catch (e) {
        log("Error fetching location: $e");
        emit(DestinationFailure());
      }
    });

    on<UpdateDestinationRating>((event, emit) async {
      try {
        await _destinationRepository.updateRating(
            event.destinationId, event.rating, user!.userId);
        await Future.delayed(const Duration(milliseconds: 300));
        add(FetchDestinations());
      } catch (e) {
        log("Error updating destination rating: $e");
      }
    });
  }
}
