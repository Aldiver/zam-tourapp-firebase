part of 'destination_bloc.dart';

abstract class DestinationEvent extends Equatable {
  const DestinationEvent();

  @override
  List<Object> get props => [];
}

class FetchDestinations extends DestinationEvent {}

class UpdateDestinationRating extends DestinationEvent {
  // final Destination destination;
  final String destinationId;
  final double rating;

  const UpdateDestinationRating({
    required this.destinationId,
    required this.rating,
  });

  @override
  List<Object> get props => [destinationId, rating];
}
