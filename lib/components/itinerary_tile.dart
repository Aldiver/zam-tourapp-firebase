import 'package:destination_repository/destination_repository.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:zc_tour_app/components/itinerary_card.dart';

class ItineraryTile extends StatelessWidget {
  final Destination destination;
  const ItineraryTile({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: TimelineTile(
        beforeLineStyle: const LineStyle(color: Colors.orangeAccent),
        indicatorStyle: IndicatorStyle(
          width: 40,
          color: Colors.orangeAccent,
          iconStyle:
              IconStyle(iconData: Icons.location_on, color: Colors.white),
        ),
        endChild: ItineraryCard(destination: destination),
      ),
    );
  }
}
