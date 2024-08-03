import 'package:flutter/material.dart';
import 'package:zc_tour_app/components/tagged_places.dart';
import 'package:zc_tour_app/screens/home/bloc/destination_bloc/destination_bloc.dart';
import 'package:zc_tour_app/utils/tags.dart';
import 'package:destination_repository/destination_repository.dart';

class TagsPlaces extends StatelessWidget {
  final DestinationSuccess state2;
  final List<Destination> mountainDestinations;
  final List<Destination> beachDestinations;
  final List<Destination> forestDestinations;
  final List<Destination> cityDestinations;
  final List<Destination> foodDestinations;
  final List<Destination> bedsDestinations;
  final List<Destination> exploreDestinations;

  const TagsPlaces({
    required this.state2,
    required this.mountainDestinations,
    required this.beachDestinations,
    required this.forestDestinations,
    required this.cityDestinations,
    required this.foodDestinations,
    required this.bedsDestinations,
    required this.exploreDestinations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final tag = tagsPlaces[index];
          List<Destination> filteredDestinations = [];

          switch (tag.name) {
            case 'Mountain':
              filteredDestinations = mountainDestinations;
              break;
            case 'Beach':
              filteredDestinations = beachDestinations;
              break;
            case 'Forest':
              filteredDestinations = forestDestinations;
              break;
            case 'City':
              filteredDestinations = cityDestinations;
              break;
            case 'Food':
              filteredDestinations = foodDestinations;
              break;
            case 'Beds':
              filteredDestinations = bedsDestinations;
              break;
            default:
              filteredDestinations = exploreDestinations;
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaggedPlaces(
                    destinationsFiltered: filteredDestinations,
                    title: tag.name,
                    state2: state2,
                  ),
                ),
              );
            },
            child: Chip(
              label: Text(tag.name),
              avatar: CircleAvatar(
                backgroundImage: AssetImage(tag.image),
              ),
              backgroundColor: Colors.white,
              elevation: 0.4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        separatorBuilder: (context, index) =>
            const Padding(padding: EdgeInsets.only(right: 10)),
        itemCount: tagsPlaces.length,
      ),
    );
  }
}
