part of 'destination_bloc.dart';

abstract class DestinationState extends Equatable {
  const DestinationState();
  @override
  List<Object> get props => [];
}

class DestinationInitial extends DestinationState {}

class DestinationLoading extends DestinationState {}

class DestinationSuccess extends DestinationState {
  final List<Destination> destinations;
  final List<Destination> exploreDestinations;
  final List<Destination> nearbyDestinations;
  final List<Destination> mountainDestinations;
  final List<Destination> beachDestinations;
  final List<Destination> forestDestinations;
  final List<Destination> cityDestinations;
  final List<Destination> foodDestinations;
  final List<Destination> bedsDestinations;
  final GeoPoint location;
  final String locationAddress;

  const DestinationSuccess(
    this.destinations,
    this.exploreDestinations,
    this.nearbyDestinations,
    this.mountainDestinations,
    this.beachDestinations,
    this.forestDestinations,
    this.cityDestinations,
    this.foodDestinations,
    this.bedsDestinations,
    this.location,
    this.locationAddress,
  );

  @override
  List<Object> get props => [
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
      ];
}

class DestinationFailure extends DestinationState {}

class DestinationError extends DestinationState {
  final String message;

  const DestinationError(this.message);
}
