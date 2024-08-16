import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:zc_tour_app/components/banner_image_widget.dart';
import 'package:zc_tour_app/components/explore_places.dart';
import 'package:zc_tour_app/components/itinerary_page.dart';
import 'package:zc_tour_app/components/nearby_places.dart';
import 'package:zc_tour_app/components/tagged_places.dart';
import 'package:zc_tour_app/components/tags_places.dart';
import 'package:zc_tour_app/components/weather_and_location.dart';
import 'package:zc_tour_app/screens/auth/blocs/sign_bloc/sign_in_bloc.dart';
import 'package:zc_tour_app/screens/home/bloc/destination_bloc/destination_bloc.dart';
import 'package:zc_tour_app/utils/weather/bloc/weather_bloc.dart';
import 'package:zc_tour_app/utils/weather/weather_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:zc_tour_app/utils/destination_filters.dart';

class HomeScreen extends StatelessWidget {
  final MyUser? user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              WeatherBloc(WeatherRepository())..add(FetchWeather()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Bienvenidos!"),
              Text(
                "${user?.name}",
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 12),
              child: IconButton(
                onPressed: () {
                  context.read<SignInBloc>().add(SignOutRequired());
                },
                icon: const Icon(Ionicons.log_out_outline),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: BlocBuilder<DestinationBloc, DestinationState>(
          builder: (context, state) {
            if (state is DestinationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DestinationSuccess) {
              final exploreDestinations =
                  getExploreDestinations(state.destinations);
              final nearbyDestinations =
                  getNearbyDestinations(state.destinations, state.location);
              final mountainDestinations =
                  filterDestinationsByTag(state.destinations, 'Mountain');
              final beachDestinations =
                  filterDestinationsByTag(state.destinations, 'Beach');
              final forestDestinations =
                  filterDestinationsByTag(state.destinations, 'Forest');
              final cityDestinations =
                  filterDestinationsByTag(state.destinations, 'City');
              final foodDestinations =
                  filterDestinationsByTag(state.destinations, 'Food');
              final bedsDestinations =
                  filterDestinationsByTag(state.destinations, 'Beds');

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(14),
                children: [
                  const WeatherAndLocation(),
                  const SizedBox(height: 15),
                  TagsPlaces(
                    state2: state,
                    mountainDestinations: mountainDestinations,
                    beachDestinations: beachDestinations,
                    forestDestinations: forestDestinations,
                    cityDestinations: cityDestinations,
                    foodDestinations: foodDestinations,
                    bedsDestinations: bedsDestinations,
                    exploreDestinations: exploreDestinations,
                  ),
                  const SizedBox(height: 10),
                  BannerImageWidget(
                    imageUrl: 'assets/images/banner_photo.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItineraryPage(
                            itinerary: exploreDestinations,
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Explore Zamboanga!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaggedPlaces(
                                destinationsFiltered: exploreDestinations,
                                title: "Explore Places",
                                state2: state,
                              ),
                            ),
                          );
                        },
                        child: const Text("View All"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const ExplorePlaces(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Places Near You",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaggedPlaces(
                                destinationsFiltered: nearbyDestinations,
                                title: "Places Near You",
                                state2: state,
                              ),
                            ),
                          );
                        },
                        child: const Text("View All"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const NearbyPlaces(),
                ],
              );
            } else {
              return const Center(child: Text('Failed to load destinations'));
            }
          },
        ),
      ),
    );
  }
}
