import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationEntity{
  String id;
  String name;
  String description;
  String coverImage;
  List<dynamic>? images;
  List<dynamic>? tags;
  bool? isFoodServiceEstablishment;
  double aveRating;
  int rating;
  String address;
  GeoPoint locationCoords;

  DestinationEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    this.images,
    this.tags,
    this.isFoodServiceEstablishment,
    required this.aveRating,
    required this.rating,
    required this.address,
    required this.locationCoords,
  });

   Map<String, Object?> toDocument() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'images': images,
      'tags': tags,
      'isFoodServiceEstablishment': isFoodServiceEstablishment ?? false,
      'aveRating': aveRating,
      'rating': rating,
      'address': address,
      'locationCoords': locationCoords,
    };
   }

   static DestinationEntity fromDocument(Map<String, dynamic> document) {
    return DestinationEntity(
      id: document['id'],
      name: document['name'],
      description: document['description'],
      coverImage: document['coverImage'],
      images: document['images'],
      tags: document['tags'],
      isFoodServiceEstablishment: document['isFoodServiceEstablishment'],
      aveRating: (document['aveRating'] as num).toDouble(),
      rating: document['rating'] ?? 0,
      address: document['address'],
      locationCoords: document['locationCoords'],
    );
   }
}