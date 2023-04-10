import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealmapper/bloc/firebase/firebase_bloc.dart';
import 'package:mealmapper/bloc/map/map_bloc.dart';
import 'package:mealmapper/models/google/nearby_search_response.dart';
import 'package:mealmapper/models/google/place_details_response.dart';
import 'package:mealmapper/models/review.dart';
import 'package:mealmapper/models/review_image.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailedBottomSheet extends StatefulWidget {
  final NearbySearchResponseResult area;
  Review? review;

  DetailedBottomSheet({super.key, required this.area, this.review});

  @override
  State<DetailedBottomSheet> createState() => _DetailedBottomSheetState();
}

class _DetailedBottomSheetState extends State<DetailedBottomSheet> {
  late bool _userDidReview;
  PlaceDetailsResponse? _placeDetailsResponse;
  List<Image> _reviewImages = [];

  @override
  void initState() {
    super.initState();
    _userDidReview = widget.review != null;
    BlocProvider.of<MapBloc>(context)
        .add(FetchPlaceDetails(widget.area.placeId));

    if (widget.review != null) {
      BlocProvider.of<FirebaseBloc>(context).add(
        GetReviewImages(widget.area.placeId, widget.review!),
      );
    }
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
      child: BlocListener<FirebaseBloc, FirebaseState>(
        listener: (context, state) {
          if (state is FetchedReviewImages) {
            for (var data in state.imagesMemory) {
              var image = Image.memory(
                data,
                height: 200,
                width: 200,
              );
              _reviewImages.add(image);
            }
            setState(() {});
          }
        },
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is FetchedPlaceDetails) {
              _placeDetailsResponse = state.response;
              return _buildDetailedColumn(context);
            }

            if (_placeDetailsResponse != null) {
              return _buildDetailedColumn(context);
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    widget.area.name ?? "Location",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8 * 4,
                ),
                Center(
                  child: Text(
                    "${widget.area.rating}/5",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8 * 4,
                ),
                _userDidReview
                    ? Center(
                        child: Text("My Review: ${widget.review!.summary}"))
                    : Center(child: Text("Rate this place!")),
                const SizedBox(
                  height: 8 * 4,
                ),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailedColumn(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              widget.area.name ?? "Location",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(
            height: 8 * 1,
          ),
          Center(
              child: Text(_placeDetailsResponse?.result?.formattedAddress ??
                  "address")),
          const SizedBox(
            height: 8 * 2,
          ),
          Center(
            child: Text(
              "${widget.area.rating}/5",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
          const SizedBox(
            height: 8 * 2,
          ),
          _userDidReview
              ? Center(
                  child: Text(
                    "My rating: ${widget.review!.rating}/5",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                )
              : const Center(
                  child: Text(
                    "My rating: ?/5",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
          const SizedBox(
            height: 8 * 4,
          ),
          _userDidReview
              ? Center(child: Text("My Review: ${widget.review!.summary}"))
              : Center(
                  child: GestureDetector(
                    onTap: () async {
                      await showDialog(
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
                ),
          const SizedBox(
            height: 8 * 4,
          ),
          _placeDetailsResponse != null &&
                  _reviewImages.isEmpty &&
                  widget.review?.images.isNotEmpty == true
              ? const Center(child: CircularProgressIndicator())
              : _reviewImages.isNotEmpty
                  ? Center(
                      child: SizedBox(
                        height: 200,
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: _reviewImages,
                        ),
                      ),
                    )
                  : Container(),
          GestureDetector(
            onTap: () async {
              var uri = Uri.parse(_placeDetailsResponse?.result?.website ?? "");
              var canLaunch = await canLaunchUrl(uri);
              if (canLaunch) {
                await launchUrl(uri);
              }
            },
            child: Text(
              _placeDetailsResponse?.result?.website ?? "address",
              style: const TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  AlertDialog _buildReviewDialog() {
    var rating = 0.0;
    var summary = "";
    bool isValid = summary.isNotEmpty;
    List<ReviewImage> images = [];
    final ImagePicker picker = ImagePicker();

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
          Row(
            children: [
              GestureDetector(
                child: const Icon(Icons.camera_alt),
                onTap: () async {
                  var image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    images.add(ReviewImage(image.path, image.name));
                  }
                },
              ),
              GestureDetector(
                child: const Icon(Icons.photo_album),
                onTap: () async {
                  var image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    images.add(ReviewImage(image.path, image.name));
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (!isValid) {
              return;
            }

            setState(() {
              _userDidReview = true;
              widget.review = Review(rating, summary, widget.area, images);
            });

            var review = Review(rating, summary, widget.area, images);

            BlocProvider.of<FirebaseBloc>(context)
                .add(UserSubmittedReview(review));

            BlocProvider.of<MapBloc>(context)
                .add(UserSubmittedReviewLocally(review));

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
