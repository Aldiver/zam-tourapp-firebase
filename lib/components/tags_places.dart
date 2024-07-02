import 'package:destination_repository/destination_repository.dart';
import 'package:flutter/material.dart';
import 'package:zc_tour_app/components/tagged_places.dart';
import 'package:zc_tour_app/screens/home/bloc/destination_bloc/destination_bloc.dart';
import 'package:zc_tour_app/utils/tags.dart';

class TagsPlaces extends StatelessWidget {
  final DestinationSuccess state2;

  const TagsPlaces({required this.state2, super.key});

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
              filteredDestinations = state2.mountainDestinations;
              break;
            case 'Beach':
              filteredDestinations = state2.beachDestinations;
              break;
            case 'Forest':
              filteredDestinations = state2.forestDestinations;
              break;
            case 'City':
              filteredDestinations = state2.cityDestinations;
              break;
            case 'Food':
              filteredDestinations = state2.foodDestinations;
              break;
            case 'Beds':
              filteredDestinations = state2.bedsDestinations;
              break;
            default:
              // Default to explore destinations
              filteredDestinations = state2.exploreDestinations;
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaggedPlaces(destinationsFiltered: filteredDestinations, title: tag.name, state2: state2,),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        separatorBuilder: (context, index) => const Padding(padding: EdgeInsets.only(right: 10)),
        itemCount: tagsPlaces.length,
      ),
    );
  }
}
