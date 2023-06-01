import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealmapper/bloc/authentication/authentication_bloc.dart';
import 'package:mealmapper/bloc/firebase/firebase_bloc.dart';
import 'package:mealmapper/bloc/map/map_bloc.dart';
import 'package:mealmapper/models/review.dart';
import 'package:mealmapper/screens/authentication_screen.dart';

class ProfileScreen extends StatefulWidget {
  List<Review>? reviews;

  ProfileScreen({super.key, this.reviews});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

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
      body: ListView(
          children: widget.reviews != null
              ? withReviewWidgets(widget.reviews!)
              : noReviewWidgets()),
    );
  }

  List<Widget> withReviewWidgets(List<Review> reviews) {
    var reviewWidgets = <Widget>[
      const Text(
        "My pins",
        style: TextStyle(
          fontSize: 32,
        ),
      ),
    ];

    var reviewTiles = reviews.map<ListTile>(
      (e) => ListTile(
        title: Text(
          e.area.name ?? "A mystery",
        ),
      ),
    );

    if (reviewTiles.length > 3) {
      reviewWidgets.addAll(reviewTiles.take(3));
      reviewWidgets
          .add(ElevatedButton(onPressed: () {}, child: Text("Show more...")));
    } else {
      reviewWidgets.addAll(reviewTiles);
    }

    reviewWidgets.addAll(noReviewWidgets());
    return reviewWidgets;
  }

  List<Widget> noReviewWidgets() {
    return [
      ElevatedButton(
        onPressed: () {
          BlocProvider.of<AuthenticationBloc>(context).add(UserSignedOut());

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
      const SizedBox(height: 24),
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return Colors.red; // Use the component's default.
            },
          ),
        ),
        onPressed: () => onDeleteAccountTapped,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Delete Account", style: TextStyle(fontSize: 24)),
        ),
      ),
    ];
  }

  Future onDeleteAccountTapped() {
    return showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content:
              Text('Deleting your account will permanently erase everything.'),
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
                    builder: (context) => const AuthenticationScreen(),
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
  }
}
