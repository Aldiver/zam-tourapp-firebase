import 'package:flutter/material.dart';
import 'package:zc_tour_app/components/destination_detail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zc_tour_app/components/distance.dart';
import 'package:zc_tour_app/screens/home/bloc/destination_bloc/destination_bloc.dart';
import 'package:zc_tour_app/utils/destination_filters.dart';

class NearbyPlaces extends StatelessWidget {
  const NearbyPlaces({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        if (state is DestinationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DestinationSuccess) {
          final nearbyDestinations =
              getNearbyDestinations(state.destinations, state.location);
          return Column(
              children: List.generate(nearbyDestinations.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                height: 160,
                width: double.maxFinite,
                child: Card(
                  elevation: 0.4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DestinationDetail(
                            destination: nearbyDestinations[index],
                            locationState: state,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                nearbyDestinations[index].coverImage,
                                height: double.maxFinite,
                                width: 130,
                                fit: BoxFit.cover,
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nearbyDestinations[index].name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(nearbyDestinations[index].address),
                                const SizedBox(height: 10),
                                // DISTANCE WIDGET
                                Distance(
                                    currentLoc: state.locationAddress,
                                    destinationLoc:
                                        nearbyDestinations[index].address),
                                const Spacer(),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellow.shade700,
                                      size: 14,
                                    ),
                                    Text(
                                      nearbyDestinations[index]
                                          .aveRating
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: nearbyDestinations[index]
                                                .distance,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }));
        } else {
          return const Center(child: Text('No nearby destinations found.'));
        }
      },
    );
  }
}
