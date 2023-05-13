import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealmapper/bloc/authentication/authentication_bloc.dart';
import 'package:mealmapper/screens/authentication_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        toolbarHeight: MediaQuery.of(context).size.height * 0.05,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: GestureDetector(
              onTap: () {
                BlocProvider.of<AuthenticationBloc>(context)
                    .add(UserSignedOut());

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const AuthenticationScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Sign out", style: TextStyle(fontSize: 48)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (builder) {
                    return AlertDialog(
                      title: Text("Are you sure?"),
                      content: Text(
                          'Deleting your account will permanently erase everything.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            BlocProvider.of<AuthenticationBloc>(context)
                                .add(UserDeletedAccount());

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AuthenticationScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Text('Yes'),
                        )
                      ],
                    );
                  },
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Delete Account", style: TextStyle(fontSize: 48)),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
