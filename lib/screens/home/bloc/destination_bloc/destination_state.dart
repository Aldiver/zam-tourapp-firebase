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

  const DestinationSuccess(
    this.destinations,
    this.location,
    this.locationAddress,
  );

  @override
  List<Object> get props => [destinations, location, locationAddress];
}

class DestinationFailure extends DestinationState {}

class DestinationError extends DestinationState {
  final String message;

  const DestinationError(this.message);
}
