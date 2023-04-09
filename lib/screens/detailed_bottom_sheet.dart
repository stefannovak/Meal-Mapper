import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mealmapper/bloc/firebase/firebase_bloc.dart';
import 'package:mealmapper/bloc/map/map_bloc.dart';
import 'package:mealmapper/models/google/nearby_search_response.dart';
import 'package:mealmapper/models/review.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailedBottomSheet extends StatefulWidget {
  final NearbySearchResponseResult area;
  final Review? review;

  const DetailedBottomSheet({super.key, required this.area, this.review});

  @override
  State<DetailedBottomSheet> createState() => _DetailedBottomSheetState();
}

class _DetailedBottomSheetState extends State<DetailedBottomSheet> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<MapBloc>(context)
        .add(FetchPlaceDetails(widget.area.placeId));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is FetchedPlaceDetails) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.area.name ?? "Location",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 8 * 1,
                ),
                Text(state.response.result?.formattedAddress ?? "address"),
                const SizedBox(
                  height: 8 * 2,
                ),
                Text(
                  "${widget.area.rating}/5",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(
                  height: 8 * 2,
                ),
                widget.review != null
                    ? Text(
                        "My rating: ${widget.review!.rating}/5",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w200,
                        ),
                      )
                    : const Text(
                        "My rating: ?/5",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                const SizedBox(
                  height: 8 * 4,
                ),
                widget.review != null
                    ? Text("My Review: ${widget.review!.summary}")
                    : GestureDetector(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return _buildReviewDialog();
                            },
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8 * 2, horizontal: 8 * 8),
                            child: Text(
                              "Rate this place! 📌",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 8 * 4,
                ),
                GestureDetector(
                  onTap: () async {
                    var uri = Uri.parse(state.response.result?.website ?? "");
                    var canLaunch = await canLaunchUrl(uri);
                    if (canLaunch) {
                      await launchUrl(uri);
                    }
                  },
                  child: Text(
                    state.response.result?.website ?? "address",
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.area.name ?? "Location",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 8 * 4,
              ),
              Text(
                "${widget.area.rating}/5",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 8 * 4,
              ),
              widget.review != null
                  ? Text("My Review: ${widget.review!.summary}")
                  : Text("Rate this place!"),
              const SizedBox(
                height: 8 * 4,
              ),
              const CircularProgressIndicator(),
            ],
          );
        },
      ),
    );
  }

  AlertDialog _buildReviewDialog() {
    var rating = 0.0;
    var summary = "";
    bool isValid = summary.isNotEmpty;

    return AlertDialog(
      title: const Text("My Review"),
      content: Column(
        children: [
          RatingBar.builder(
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rate) {
              rating = rate;
            },
            allowHalfRating: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'What did you think?',
                hintMaxLines: 5,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8 * 8,
                  horizontal: 8 * 1,
                ),
              ),
              onChanged: (text) {
                setState(() {
                  summary = text;
                  isValid = summary.isNotEmpty;
                });
              },
            ),
          ),
          TextField(), // Photos
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (!isValid) {
              return;
            }

            BlocProvider.of<FirebaseBloc>(context).add(
              UserSubmittedReview(
                Review(
                  rating,
                  summary,
                  widget.area,
                ),
              ),
            );

            Navigator.pop(context);
          },
          child: Text(
            "Submit",
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isValid ? Colors.blue : Colors.grey,
            ),
          ),
        )
      ],
    );
  }
}
