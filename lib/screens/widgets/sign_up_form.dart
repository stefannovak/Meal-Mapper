import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealmapper/bloc/authentication/authentication_bloc.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  SignUpFormState createState() {
    return SignUpFormState();
  }
}

class SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String? email;
    String? password;
    String? confirmPassword;

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(label: Text("Email")),
            onChanged: (value) => email = value,
            validator: (value) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
          ),
          TextFormField(
            decoration: const InputDecoration(label: Text("Password")),
            onChanged: (value) => password = value,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              if (!isValidPassword(value)) {
                return 'Invalid password';
              }
              if (value != confirmPassword) {
                return "Passwords do not match";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(label: Text("Confirm Password")),
            onChanged: (value) => confirmPassword = value,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              if (!isValidPassword(value)) {
                return 'Invalid password';
              }
              if (value != password) {
                return "Passwords do not match";
              }
              return null;
            },
          ),
          const SizedBox(height: 8 * 2),
          ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate() &&
                  email != null &&
                  password != null &&
                  confirmPassword != null) {
                BlocProvider.of<AuthenticationBloc>(context).add(
                  UserCreatedAccount(
                    email!,
                    password!,
                  ),
                );
              }
            },
            child: const Text('Sign up'),
          ),
        ],
      ),
    );
  }
}

bool isValidPassword(String value) {
  RegExp passwordRegex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  return passwordRegex.hasMatch(value);
}
