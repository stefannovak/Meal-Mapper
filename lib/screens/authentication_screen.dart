import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealmapper/bloc/authentication/authentication_bloc.dart';
import 'package:mealmapper/screens/home_page.dart';

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Dank app",
                style: TextStyle(fontSize: 52),
              ),
              const SizedBox(
                height: 32,
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your email address',
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your password',
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Container(
                decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                child: GestureDetector(
                  onTap: () {
                    BlocProvider.of<AuthenticationBloc>(context).add(
                      UserLoggedIn(
                        'stefannovak96@gmail.com',
                        'Password123!',
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Log in", style: TextStyle(fontSize: 48)),
                  ),
                ),
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
    );
  }
}
