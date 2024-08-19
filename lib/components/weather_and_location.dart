import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zc_tour_app/utils/weather/bloc/weather_bloc.dart';

class WeatherAndLocation extends StatelessWidget {
  const WeatherAndLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) {
            return const CircularProgressIndicator();
          } else if (state is WeatherLoaded) {
            final weather = state.weather;
            return Card(
                elevation: 0.4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(children: [
                    Image.asset(
                      'assets/images/satellite-view.png',
                      width: 64,
                    ),
                    // ignore: prefer_const_constructors
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${weather['current']['temp_c']} °C, ${weather['current']['condition']['text']}",
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${weather['location']['name']}, ${weather['location']['region']}",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        // Image.network(
                        //   'http:${weather['current']['condition']['icon']}',
                        //   height: 64,
                        //   width: 64,
                        //   fit: BoxFit.fill,
                        // ),
                      ],
                    ),
                  ]),
                )
                // Row(
                //   children: [
                //     Image.network(
                //       'http:${weather['current']['condition']['icon']}',
                //       height: 100,
                //       width: 100,
                //       fit: BoxFit.fill,
                //     ),
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           '${weather['current']['condition']['text']}',
                //           style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                //                 color: Colors.black,
                //               ),
                //         ),
                //         Text(
                //           '${weather['location']['name']}',
                //           style: Theme.of(context).textTheme.labelSmall
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                );
          } else if (state is WeatherError) {
            // return Text(state.message);
            return const Center(
              child: Text('There was a problem fetching the weather data.'),
            );
          } else {
            return const Text('Press button to fetch weather');
          }
        },
      ),
    );
  }
}
