import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zc_tour_app/components/itinerary_page.dart';
import 'package:zc_tour_app/screens/home/bloc/destination_bloc/destination_bloc.dart';

class ItinerariesList extends StatelessWidget {
  const ItinerariesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (BuildContext context, DestinationState state) {
        if (state is DestinationSuccess) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Suggested Itineraries"),
            ),
            body: ListView.builder(
              itemCount: state.itineraries.length,
              itemBuilder: (context, index) {
                final itinerary = state.itineraries[index];
                final color = Colors.primaries[index %
                    Colors.primaries.length]; // Different color for each card

                return GestureDetector(
                  onTap: () {
                    // Fetch destinations based on itinerary
                    final destinationIds = itinerary.destinations;
                    final destinations = state.destinations
                        .where((dest) => destinationIds!.contains(dest.id))
                        .toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItineraryPage(
                          itinerary: destinations,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: color,
                    elevation: 5.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            itinerary.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
