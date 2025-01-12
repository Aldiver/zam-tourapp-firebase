import 'package:destination_repository/destination_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zc_tour_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:zc_tour_app/screens/auth/views/welcome_screen.dart';
import 'package:zc_tour_app/screens/home/bloc/destination_bloc/destination_bloc.dart';
import 'package:zc_tour_app/screens/home/views/home_screen.dart';
import 'package:zc_tour_app/screens/auth/blocs/sign_bloc/sign_in_bloc.dart';

// ignore: camel_case_types
class zc_tour_appView extends StatelessWidget {
  const zc_tour_appView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>.value(
          value: BlocProvider.of<AuthenticationBloc>(context),
        ),
        BlocProvider<SignInBloc>(
          create: (context) =>
              SignInBloc(context.read<AuthenticationBloc>().userRepository),
        ),
        BlocProvider<DestinationBloc>(
          create: (context) => DestinationBloc(
            FirebaseDestinationRepo(),
            context.read<AuthenticationBloc>(),
          )..add(FetchDestinations()),
        ),
        // Add other BlocProviders here if needed
      ],
      child: MaterialApp(
        title: 'Zamboanga Tour App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.mulishTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: ((context, state) {
            if (state.status == AuthenticationStatus.authenticated) {
              return HomeScreen(user: state.user);
            } else {
              return const WelcomeScreen();
            }
          }),
        ),
      ),
    );
  }
}
