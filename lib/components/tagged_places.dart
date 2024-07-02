import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:destination_repository/destination_repository.dart';
import 'package:ionicons/ionicons.dart';
import 'package:zc_tour_app/components/destination_details.dart';
import 'package:zc_tour_app/screens/home/bloc/destination_bloc/destination_bloc.dart';

class TaggedPlaces extends StatelessWidget {
  final List<Destination> destinationsFiltered;
  final String title;
  final DestinationSuccess state2;
  const TaggedPlaces(
      {super.key,
      required this.destinationsFiltered,
      required this.title,
      required this.state2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: destinationsFiltered.isEmpty
          ? const Center(
              child: Text('No destinations available'),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  children: destinationsFiltered.map((destination) {
                    return Card(
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
                              builder: (context) => DestinationPage(
                                destination: destination,
                                state2: state2,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  destination.coverImage,
                                  width: double.maxFinite,
                                  fit: BoxFit.cover,
                                  height: 150,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                destination.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines:
                                        1, // Adjust based on your requirement
                                    overflow: TextOverflow
                                        .ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow.shade700,
                                    size: 14,
                                  ),
                                  Text(
                                    destination.aveRating.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Ionicons.location,
                                    color: Theme.of(context).primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      destination.address,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
