import 'dart:developer';

import 'package:destination_repository/destination_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:zc_tour_app/components/distance.dart';
import 'package:zc_tour_app/screens/home/bloc/destination_bloc/destination_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

class DestinationPage extends StatefulWidget {
  final Destination destination;
  final DestinationSuccess state2;

  const DestinationPage({
    super.key,
    required this.destination,
    required this.state2,
  });

  @override
  State<DestinationPage> createState() => _DestinationPage();
}

class _DestinationPage extends State<DestinationPage> {
  GoogleMapController? mapController; //contrller for Google map
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyC5xwympP_6R7-o7QT2WsC0un--wyGZydM";

  Set<Marker> markers = {}; //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  late LatLng startLocation;
  late LatLng endLocation;

  bool isDescriptionExpanded = false;
  late double? distanceInMeters;

  @override
  void initState() {
    startLocation = LatLng(
      widget.state2.location.latitude,
      widget.state2.location.longitude,
    );
    endLocation = LatLng(
      widget.destination.locationCoords.latitude,
      widget.destination.locationCoords.longitude,
    );

    markers.add(Marker(
      //add start location marker
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
    final distanceString = widget.destination.distance;
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                        image: NetworkImage(widget.destination.coverImage),
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
                        widget.destination.name,
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
                              widget.destination.address,
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
                      widget.destination.aveRating.toString(),
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
                  widget.destination.description,
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
            if (widget.destination.menu != null)
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
                    itemCount: widget.destination.menu!.items.length,
                    itemBuilder: (context, index) {
                      final menuItem = widget.destination.menu!.items[index];
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
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menuItem.menuItem,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.visible,
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
                        ),
                      );
                    },
                  ),
                ],
              ),

            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "More Images",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => TaggedPlaces(destinationsFiltered: exploreDestinations, title: "Explore Places", state2: state),
                    //   ),
                    // );
                  },
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 5),
            //Images
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  widget.destination.images!.length > 4
                      ? 4
                      : widget.destination.images!.length,
                  (index) {
                    if (index == 3 && widget.destination.images!.length > 4) {
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
                                itemCount: widget.destination.images?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        widget.destination.images?[index],
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
                                widget.destination.images?[index],
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                              ),
                            ),
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Text(
                                "+${widget.destination.images!.length - 4}",
                                style: const TextStyle(color: Colors.white),
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
                                  widget.destination.images?[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            widget.destination.images?[index],
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

            //end Images
            const SizedBox(height: 5),
            const Divider(),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Estimated distance: ${widget.destination.distance}",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
                currentLoc: widget.state2.locationAddress,
                destinationLoc: widget.destination.address),
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
                      'https://www.google.com/maps/dir/?api=1&origin=${widget.state2.location.latitude},${widget.state2.location.longitude}&destination=${widget.destination.locationCoords.latitude},${widget.destination.locationCoords.longitude}&travelmode=driving');

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
  }
}
