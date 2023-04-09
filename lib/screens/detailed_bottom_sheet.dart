import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                const Text(
                  "My rating: ?/5",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(
                  height: 8 * 4,
                ),
                GestureDetector(
                  onTap: () async {
                    BlocProvider.of<FirebaseBloc>(context).add(
                      UserSubmittedReview(
                        Review(
                          5,
                          "Amazing place!",
                          widget.area,
                        ),
                      ),
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
              Text("Rate this place!"),
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
}
