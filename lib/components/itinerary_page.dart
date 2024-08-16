import 'package:destination_repository/destination_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zc_tour_app/components/itinerary_tile.dart';
import 'package:zc_tour_app/screens/home/bloc/destination_bloc/destination_bloc.dart';

class ItineraryPage extends StatelessWidget {
  final List<Destination> itinerary;
  const ItineraryPage({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (BuildContext context, DestinationState state) {
        if (state is DestinationSuccess) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Your Itinerary"),
            ),
            body: Padding(
              padding: const EdgeInsets.only(left: 50),
              child: ListView(
                children: itinerary.map(
                  (item) {
                    // Pass the item to ItineraryTile
                    return ItineraryTile(destination: item);
                  },
                ).toList(), // Convert iterable to list
              ),
            ),
          );
        } else if (state is DestinationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('Failed to load itinerary'));
        }
      },
    );
  }
}
