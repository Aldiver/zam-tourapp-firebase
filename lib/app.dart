import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'app_view.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';

// ignore: camel_case_types
class zc_tour_app extends StatelessWidget {
  final UserRepository userRepository;
  const zc_tour_app(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UserRepository>.value(
      value: userRepository,
      child: BlocProvider<AuthenticationBloc>(
        create: (context) => AuthenticationBloc(
          userRepository: userRepository,
        ),
        child: const zc_tour_appView(),
      ),
    );
  }
}
