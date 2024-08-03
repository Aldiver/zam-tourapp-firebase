import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/entities.dart';
import 'menu.dart';

class Destination {
  String id;
  String name;
  String description;
  String coverImage;
  List<dynamic>? images;
  List<dynamic>? tags;
  bool? isFoodServiceEstablishment;
  Menu? menu;
  double? userRating;
  double? aveRating;
  int? rating;
  String address;
  GeoPoint locationCoords;
  String? distance;
  Map<String, dynamic>? matrix;
  String? ratingId;

  Destination(
      {required this.id,
      required this.name,
      required this.description,
      required this.coverImage,
      this.images,
      this.tags,
      this.isFoodServiceEstablishment,
      this.menu,
      this.userRating,
      this.aveRating,
      this.rating,
      required this.address,
      required this.locationCoords,
      this.distance,
      this.matrix,
      this.ratingId});

  static final empty = Destination(
    id: '',
    name: '',
    description: '',
    coverImage: '',
    images: [],
    tags: [],
    isFoodServiceEstablishment: false,
    menu: null,
    userRating: 0.0,
    aveRating: 0.0,
    rating: 0,
    address: '',
    locationCoords: const GeoPoint(0.0, 0.0),
    distance: "",
    matrix: {},
    ratingId: "",
  );

  DestinationEntity toEntity() {
    return DestinationEntity(
      id: id,
      name: name,
      description: description,
      coverImage: coverImage,
      images: images,
      tags: tags,
      isFoodServiceEstablishment: isFoodServiceEstablishment,
      aveRating: aveRating!,
      rating: rating!,
      address: address,
      locationCoords: locationCoords,
    );
  }

  static Destination fromEntity(DestinationEntity entity) {
    return Destination(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      coverImage: entity.coverImage,
      images: entity.images,
      tags: entity.tags,
      isFoodServiceEstablishment: entity.isFoodServiceEstablishment,
      aveRating: entity.aveRating,
      rating: entity.rating,
      address: entity.address,
      locationCoords: entity.locationCoords,
    );
  }

  @override
  String toString() {
    return 'Destination{id: $id, name: $name, description: $description, coverImage: $coverImage, images: $images, tags: $tags, isFoodServiceEstablishment: $isFoodServiceEstablishment, rating: $rating, address: $address, locationCoords: $locationCoords}';
  }
}
