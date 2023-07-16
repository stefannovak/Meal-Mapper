import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealmapper/bloc/authentication/authentication_bloc.dart';
import 'package:mealmapper/bloc/firebase/firebase_bloc.dart';
import 'package:mealmapper/bloc/map/map_bloc.dart';
import 'package:mealmapper/models/review.dart';
import 'package:mealmapper/screens/authentication_screen.dart';

// Global
bool joeIsPendingRequest = true;
bool samIsPendingRequest = true;
bool hasSharedJoeReviews = false;
bool hasSharedSamReviews = false;

class ProfileScreen extends StatefulWidget {
  List<Review>? reviews;

  ProfileScreen({super.key, this.reviews});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int showingReviews = 0;

  @override
  void initState() {
    showingReviews = widget.reviews != null ? 5 : 0;
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
              ? withReviewWidgets(widget.reviews!, showingReviews)
              : noReviewWidgets()),
    );
  }

  List<Widget> withReviewWidgets(
    List<Review> reviews,
    int amountOfReviewsToShow,
  ) {
    var reviewWidgets = <Widget>[
      const Text(
        "My reviews",
        style: TextStyle(
          fontSize: 32,
        ),
        textAlign: TextAlign.center,
      ),
    ];

    var reviewTiles = reviews
        .take(amountOfReviewsToShow)
        .map<ListTile>(
          (e) => ListTile(
            title: Text(
              e.area.name ?? "A mystery",
            ),
            subtitle: Text(e.area.vicinity ?? ""),
            trailing: Text(e.rating.toString()),
          ),
        )
        .toList();

    reviewWidgets.addAll(reviewTiles);

    if (!(showingReviews >= reviews.length)) {
      reviewWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              showingReviews += 5;
            });
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Show more..."),
          ),
        ),
      );

      reviewWidgets.add(const SizedBox(
        height: 16,
      ));
    } else {
      reviewWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              showingReviews = 5;
            });
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Show less..."),
          ),
        ),
      );
    }

    reviewWidgets.addAll(noReviewWidgets());

    return reviewWidgets;
  }

  List<Widget> noReviewWidgets() {
    return [
      Container(
        height: 1,
        color: Colors.grey,
      ),
      const Text(
        "My friends",
        style: TextStyle(
          fontSize: 32,
        ),
        textAlign: TextAlign.center,
      ),
      createJoeFriendTile(),
      createSamFriendTile(),
      Container(
        height: 1,
        color: Colors.grey,
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.blue,
            onPressed: () {
              BlocProvider.of<AuthenticationBloc>(context).add(UserSignedOut());

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const AuthenticationScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text("Sign out", style: Theme.of(context).textTheme.titleLarge),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => onDeleteAccountTapped,
            color: Colors.red,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Delete Account",
                style: Theme.of(context).textTheme.titleLarge),
          ),
        ],
      ),
    ];
  }

  ListTile createSamFriendTile() {
    return ListTile(
      title: const Text(
        "Sam Butcher",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      subtitle: Text(samIsPendingRequest
          ? "Wants to be your friend!"
          : hasSharedSamReviews
              ? "Reviews shared"
              : "Share reviews!"),
      onTap: () async {
        if (samIsPendingRequest) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Do you want to accept this friend request?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        samIsPendingRequest = false;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Yes"),
                  ),
                ],
              );
            },
          );
        }

        if (!hasSharedSamReviews && mounted) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title:
                    const Text("Do you want to share your reviews with Sam?"),
                content: const Text(
                    "Sharing your reviews will allow you and Sam to see each others reviews on your maps. They will show up as orange markers."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        hasSharedSamReviews = true;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Yes"),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  ListTile createJoeFriendTile() {
    return ListTile(
      title: const Text(
        "Joe Smith",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      subtitle: Text(joeIsPendingRequest
          ? "Wants to be your friend!"
          : hasSharedJoeReviews
              ? "Reviews shared"
              : "Share reviews!"),
      onTap: () async {
        if (joeIsPendingRequest) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Do you want to accept this friend request?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        joeIsPendingRequest = false;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Yes"),
                  ),
                ],
              );
            },
          );
        }

        if (!hasSharedSamReviews && mounted) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title:
                    const Text("Do you want to share your reviews with Joe?"),
                content: const Text(
                    "Sharing your reviews will allow you and Joe to see each others reviews on your maps. They will show up as orange markers."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        hasSharedJoeReviews = true;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Yes"),
                  ),
                ],
              );
            },
          );
        }
      },
    );
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
