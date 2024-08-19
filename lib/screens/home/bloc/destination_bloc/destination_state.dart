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
  final GeoPoint location;
  final String locationAddress;
  final List<Itinerary> itineraries;

  const DestinationSuccess(
      this.destinations, this.location, this.locationAddress, this.itineraries);

  @override
  List<Object> get props =>
      [destinations, location, locationAddress, itineraries];
}

class DestinationFailure extends DestinationState {}

class DestinationError extends DestinationState {
  final String message;

  const DestinationError(this.message);
}
