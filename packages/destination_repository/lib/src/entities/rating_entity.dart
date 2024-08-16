class RatingEntity {
  final String destinationId;
  final String userId;
  final double rating;

  RatingEntity({
    required this.destinationId,
    required this.userId,
    required this.rating,
  });

  static final empty = RatingEntity(
    destinationId: '',
    userId: '',
    rating: 0.0,
  );

  factory RatingEntity.fromDocument(Map<String, dynamic> doc) {
    return RatingEntity(
      destinationId: doc['destinationId'],
      userId: doc['userId'],
      rating: (doc['rating'] as num).toDouble(),
    );
  }
}
