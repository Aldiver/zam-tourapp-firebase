import 'dart:developer';

import 'package:destination_repository/destination_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zc_tour_app/components/distance.dart';
import 'package:zc_tour_app/screens/home/bloc/destination_bloc/destination_bloc.dart';

class DestinationDetail extends StatefulWidget {
  final Destination destination;
  final DestinationSuccess locationState;

  const DestinationDetail(
      {super.key, required this.destination, required this.locationState});

  @override
  State<DestinationDetail> createState() => _DestinationDetailState();
}

class _DestinationDetailState extends State<DestinationDetail> {
  late Destination destination;
  GoogleMapController? mapController; //contrller for Google map
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyC5xwympP_6R7-o7QT2WsC0un--wyGZydM";

  Set<Marker> markers = {}; //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  late LatLng startLocation;
  late LatLng endLocation;

  bool isDescriptionExpanded = false;
  late double? distanceInMeters;
  late String locationAddress;
  LatLng? stateLocation;
  DestinationSuccess? currentState;

  @override
  void initState() {
    super.initState();
    destination = widget.destination;
    startLocation = LatLng(
      widget.locationState.location.latitude,
      widget.locationState.location.longitude,
    );
    endLocation = LatLng(
      destination.locationCoords.latitude,
      destination.locationCoords.longitude,
    );

    locationAddress = widget.locationState.locationAddress;

    markers.add(Marker(
      markerId: MarkerId(startLocation.toString()),
      position: startLocation, //position of marker
      infoWindow: const InfoWindow(
        //popup info
        title: 'Starting Point ',
        snippet: 'Start Marker',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    markers.add(Marker(
      //add distination location marker
      markerId: MarkerId(endLocation.toString()),
      position: endLocation, //position of marker
      infoWindow: const InfoWindow(
        //popup info
        title: 'Destination Point ',
        snippet: 'Destination Marker',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    getDirections(); //fetch direction polylines from Google API

    super.initState();
  }

  getDirections() async {
    final distanceString = destination.distance;
    if (distanceString != null && distanceString.isNotEmpty) {
      final numericDistance =
          double.tryParse(distanceString.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (numericDistance != null) {
        // Check for unit (meters or kilometers) and convert to meters
        if (distanceString.toLowerCase().contains('km')) {
          // Convert kilometers to meters
          distanceInMeters = numericDistance * 1000;
        } else {
          distanceInMeters = numericDistance;
        }
      }
    }

    if (distanceInMeters == null) {
      // Handle null or invalid distance value
      log('Invalid distance value');
    } else {
      log('Distance in meters: $distanceInMeters');
    }

    // Check if the distance is less than 50 km
    if (distanceInMeters! < 50000) {
      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(startLocation.latitude, startLocation.longitude),
        PointLatLng(endLocation.latitude, endLocation.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
        addPolyLine(polylineCoordinates);
      } else {
        log(result.errorMessage.toString());
      }
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  void _fitMapToMarkers(GoogleMapController controller) {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        startLocation.latitude < endLocation.latitude
            ? startLocation.latitude
            : endLocation.latitude,
        startLocation.longitude < endLocation.longitude
            ? startLocation.longitude
            : endLocation.longitude,
      ),
      northeast: LatLng(
        startLocation.latitude > endLocation.latitude
            ? startLocation.latitude
            : endLocation.latitude,
        startLocation.longitude > endLocation.longitude
            ? startLocation.longitude
            : endLocation.longitude,
      ),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        50, // padding
      ),
    );
  }

  void _showRatingDialog({required double rating}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Rate this Destination"),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: RatingBar.builder(
              initialRating: rating,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (newRating) {
                rating = newRating;
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text("Rate"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Update the destination rating in the state and database
                context.read<DestinationBloc>().add(
                      UpdateDestinationRating(
                        destinationId: destination.id,
                        rating: rating,
                      ),
                    );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double averageRating;
    double userRating;
    int ratings;
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        if (state is DestinationLoading) {
          averageRating = 0.0;
          userRating = 0.0;
          ratings = 0;
        } else if (state is DestinationSuccess) {
          final matchingDestination = state.destinations.firstWhere(
            (d) =>
                d.id == destination.id, // Example comparison; adjust as needed
          );
          averageRating = matchingDestination.aveRating!;
          userRating = matchingDestination.userRating!;
          ratings = matchingDestination.rating!;
        } else {
          averageRating = 0.0;
          userRating = 0.0;
          ratings = 0;
        }
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                SizedBox(
                  height: size.height * 0.38,
                  width: double.maxFinite,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(destination.coverImage),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              spreadRadius: 0,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                iconSize: 20,
                                icon: const Icon(Ionicons.chevron_back),
                              ),
                              IconButton(
                                iconSize: 20,
                                onPressed: () {},
                                icon: const Icon(Ionicons.heart_outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination.name,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.visible,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Ionicons.location, size: 15),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  destination.address,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Ionicons.star,
                          color: Colors.yellow[800],
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          averageRating.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.description,
                      textAlign: TextAlign.justify,
                      maxLines: isDescriptionExpanded ? null : 4,
                      overflow: isDescriptionExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isDescriptionExpanded = !isDescriptionExpanded;
                        });
                      },
                      child: Text(
                        isDescriptionExpanded ? "See less" : "See more",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                //menu
                if (destination.menu != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Menu",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2,
                        ),
                        itemCount: destination.menu!.items.length,
                        itemBuilder: (context, index) {
                          final menuItem = destination.menu!.items[index];
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    menuItem.menuItem,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "P ${menuItem.price.toString()}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 5),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "More Images",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () {
                    //     // Navigator.push(
                    //     //   context,
                    //     //   MaterialPageRoute(
                    //     //     builder: (context) => TaggedPlaces(destinationsFiltered: exploreDestinations, title: "Explore Places", state2: state),
                    //     //   ),
                    //     // );
                    //   },
                    //   child: const Text("View All"),
                    // ),
                  ],
                ),
                const SizedBox(height: 5),
                //Images
                SizedBox(
                  height: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        destination.images!.length > 4
                            ? 4
                            : destination.images!.length,
                        (index) {
                          if (index == 3 && destination.images!.length > 4) {
                            return GestureDetector(
                              onTap: () {
                                // Show all images in a grid view modal
                                showDialog(
                                  context: context,
                                  barrierColor:
                                      const Color.fromARGB(199, 255, 255, 255),
                                  builder: (context) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                      ),
                                      itemCount: destination.images?.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              destination.images?[index],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.network(
                                      destination.images?[index],
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                                  Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Text(
                                      "+${destination.images!.length - 4}",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                // Show image preview in a modal
                                showDialog(
                                  context: context,
                                  barrierColor:
                                      const Color.fromARGB(50, 255, 255, 255),
                                  builder: (context) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        destination.images?[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(
                                  destination.images?[index],
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                //end Images
                const SizedBox(height: 5),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    _showRatingDialog(rating: userRating);
                  },
                  child: Row(
                    children: [
                      Text(
                        averageRating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.star,
                        color: Colors.yellow.shade700,
                        size: 20,
                      ),
                      Text(
                        'Destination Ratings (${ratings.toString()})',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                // ElevatedButton(
                //   onPressed: _showRatingDialog,
                //   child: RatingBar.builder(
                //     initialRating: average_rating,
                //     ignoreGestures: true,
                //     minRating: 1,
                //     allowHalfRating: true,
                //     itemCount: 5,
                //     itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                //     itemBuilder: (context, _) => const Icon(
                //       Icons.star,
                //       color: Colors.amber,
                //     ),
                //     onRatingUpdate: (newRating) {
                //       average_rating = newRating;
                //     },
                //   ),
                // ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Estimated distance: ${destination.distance}",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 5),
                        // Text(
                        //   "Started in",
                        //   style: Theme.of(context).textTheme.bodySmall,
                        // ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
                  width: double.maxFinite,
                  child: GoogleMap(
                    zoomGesturesEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: startLocation,
                      zoom: 10.0,
                    ),
                    markers: markers,
                    polylines: Set<Polyline>.of(polylines.values),
                    mapType: MapType.normal,
                    onMapCreated: (controller) {
                      mapController = controller;
                      _fitMapToMarkers(controller);
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Distance(
                    currentLoc: locationAddress,
                    destinationLoc: destination.address),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (distanceInMeters! > 50000) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Distance too far"),
                          content: const Text(
                              "The destinatino is too far to calculate directions."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      final Uri url = Uri.parse(
                          'https://www.google.com/maps/dir/?api=1&origin=${startLocation.latitude},${startLocation.longitude}&destination=${endLocation.latitude},${endLocation.longitude}&travelmode=driving');

                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 8.0,
                    ),
                  ),
                  child: const Text("Get Directions"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
