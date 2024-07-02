import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zc_tour_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:zc_tour_app/screens/auth/blocs/sign_up/sign_up_bloc.dart';
import 'package:user_repository/user_repository.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool signUpRequired = false;
  bool _isConfirmPasswordVisible = false;
  String _errorMsg = '';

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          setState(() {
            signUpRequired = false;
          });
          final user = MyUser(
            userId: '', // Generate or fetch this as needed
            email: _emailController.text,
            name: _nameController.text,
            role: 'user', // Default role
          );
          // context.read<AuthenticationBloc>().add(AuthenticationUserChanged(user));
          // Navigate to the HomeScreen, you can use Navigator.pushReplacement if needed
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign up successful!')));
        } else if (state is SignUpLoading) {
          setState(() {
            signUpRequired = true;
          });
          // Handle loading state if needed
        } else if (state is SignUpFailure) {
          setState(() {
            signUpRequired = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Sign up failed. Please try again.')));
        }
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: SvgPicture.asset(
                          'assets/images/app_logo.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildTextField(_nameController, 'Name'),
                            const SizedBox(height: 15.0),
                            _buildTextField(_emailController, 'Email'),
                            const SizedBox(height: 15.0),
                            _buildPasswordField(_passwordController, 'Password',
                                _isPasswordVisible, () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            }),
                            const SizedBox(height: 15.0),
                            _buildPasswordField(
                                _confirmPasswordController,
                                'Confirm Password',
                                _isConfirmPasswordVisible, () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            }),
                            const SizedBox(height: 20.0),
                            GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_passwordController.text ==
                                      _confirmPasswordController.text) {
                                    final user = MyUser(
                                      userId:
                                          '', // Generate or fetch this as needed
                                      email: _emailController.text,
                                      name: _nameController.text,
                                      role: 'user', // Default role
                                    );
                                    setState(() {
                                      context.read<SignUpBloc>().add(
                                            SignUpRequired(
                                                user, _passwordController.text),
                                          );
                                    });
                                  } else {
                                    setState(() {
                                      _errorMsg = 'Passwords do not match';
                                    });
                                  }
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 13.0, horizontal: 30.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: signUpRequired
                                      ? const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        )
                                      : const Text(
                                          "Sign Up",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                ),
                              ),
                            ),
                            if (_errorMsg.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                _errorMsg,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
      decoration: BoxDecoration(
        color: const Color(0xFFedf0f8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hintText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hintText,
      bool isPasswordVisible, VoidCallback toggleVisibility) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
      decoration: BoxDecoration(
        color: const Color(0xFFedf0f8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: toggleVisibility,
          ),
        ),
        obscureText: !isPasswordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hintText';
          }
          return null;
        },
      ),
    );
  }
}
