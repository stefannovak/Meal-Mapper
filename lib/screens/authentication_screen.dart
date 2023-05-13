import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealmapper/bloc/authentication/authentication_bloc.dart';
import 'package:mealmapper/screens/home_page.dart';
import 'package:mealmapper/screens/widgets/email_password_form.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationSuccess) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MyHomePage(),
            ),
          );
        }
        if (state is AuthenticationFailure) {
          print('something went wrong');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8 * 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Meal Mapper",
                  style: TextStyle(fontSize: 52),
                ),
                const SizedBox(
                  height: 32,
                ),
                EmailPasswordForm(),
                const SizedBox(
                  height: 8 * 4,
                ),
                GestureDetector(
                  onTap: () {
                    BlocProvider.of<AuthenticationBloc>(context).add(
                      UserCreatedAccount(
                        'stefannovak96@gmail.com',
                        'Password123!',
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Or, sign up", style: TextStyle(fontSize: 34)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
