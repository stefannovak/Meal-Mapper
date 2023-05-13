import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealmapper/bloc/authentication/authentication_bloc.dart';

class EmailPasswordForm extends StatefulWidget {
  const EmailPasswordForm({super.key});

  @override
  EmailPasswordFormState createState() {
    return EmailPasswordFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class EmailPasswordFormState extends State<EmailPasswordForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String? email;
    String? password;

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(label: Text("Email")),
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
            decoration: InputDecoration(label: Text("Password")),
            onChanged: (value) => password = value,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          SizedBox(height: 8 * 2),
          ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate() &&
                  email != null &&
                  password != null) {
                BlocProvider.of<AuthenticationBloc>(context).add(
                  UserLoggedIn(
                    email!,
                    password!,
                  ),
                );
              }
            },
            child: const Text('Log in'),
          ),
        ],
      ),
    );
  }
}
