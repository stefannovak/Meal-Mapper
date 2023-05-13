import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealmapper/bloc/authentication/authentication_bloc.dart';
import 'package:mealmapper/screens/home_page.dart';
import 'package:mealmapper/screens/widgets/email_password_form.dart';
import 'package:mealmapper/screens/widgets/sign_up_form.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool isLogInScreen = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MyHomePage(),
            ),
            (Route<dynamic> route) => false,
          );

          var t = 't';
        }
        if (state is AuthenticationFailure) {
          print('something went wrong');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLogInScreen ? _buildLogInScreen() : _buildSignUpScreen(),
      ),
    );
  }

  Widget _buildLogInScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8 * 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png"),
            const SizedBox(
              height: 32,
            ),
            const EmailPasswordForm(),
            const SizedBox(
              height: 8 * 2,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLogInScreen = false;
                });
              },
              child: const Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8 * 4),
        child: ListView(
          children: [
            Image.asset("assets/images/logo.png"),
            const Center(child: Text("Create an account")),
            const SizedBox(
              height: 32,
            ),
            const SignUpForm(),
            const SizedBox(
              height: 8 * 2,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLogInScreen = true;
                });
              },
              child: const Text('Back to log in'),
            ),
          ],
        ),
      ),
    );
  }
}
