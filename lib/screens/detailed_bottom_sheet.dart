import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealmapper/bloc/firebase/firebase_bloc.dart';
import 'package:mealmapper/bloc/map/map_bloc.dart';
import 'package:mealmapper/models/friend_reviews.dart';
import 'package:mealmapper/models/google/nearby_search_response.dart';
import 'package:mealmapper/models/google/place_details_response.dart';
import 'package:mealmapper/models/review.dart';
import 'package:mealmapper/models/review_image.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailedBottomSheet extends StatefulWidget {
  final NearbySearchResponseResult area;
  Review? review;
  String? friendName;

  DetailedBottomSheet({
    super.key,
    required this.area,
    this.review,
    this.friendName,
  });

  @override
  State<DetailedBottomSheet> createState() => _DetailedBottomSheetState();
}

class _DetailedBottomSheetState extends State<DetailedBottomSheet> {
  PlaceDetailsResponse? _placeDetailsResponse;
  final List<Image> _reviewImages = [];

  @override
  void initState() {
    super.initState();
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
      child: BlocBuilder<FirebaseBloc, FirebaseState>(
        builder: (context, state) {
          if (state is FetchedReviewImages) {
            for (var data in state.imagesMemory) {
              var image = Image.memory(
                data,
                height: 200,
                width: 200,
              );
              _reviewImages.add(image);
            }
          }

          return BlocBuilder<MapBloc, MapState>(
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
                  widget.review != null
                      ? Center(
                          child: Text(
                              "${widget.friendName?.isNotEmpty == true ? "${widget.friendName}'s" : "My"} Review: ${widget.review!.summary}"))
                      : const Center(child: Text("Rate this place!")),
                  const SizedBox(
                    height: 8 * 4,
                  ),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailedColumn(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buildReviewChildren(context),
      ),
    );
  }

  List<Widget> buildReviewChildren(BuildContext context) {
    return [
      Center(
        child: Text(
          widget.area.name ?? "Establishment",
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(
        height: 8 * 1,
      ),
      Center(
        child: widget.area.rating == null
            ? const Text(
                "No reviews yet",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w200,
                ),
              )
            : Column(
                children: [
                  RatingBar.builder(
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amberAccent,
                    ),
                    onRatingUpdate: (_) {},
                    allowHalfRating: true,
                    initialRating: widget.area.rating!.toDouble(),
                  ),
                  Text(widget.area.rating!.toString()),
                ],
              ),
      ),
      const SizedBox(
        height: 8 * 2,
      ),
      _placeDetailsResponse?.result?.formattedAddress != null
          ? Text(_placeDetailsResponse!.result!.formattedAddress!)
          : Container(),
      const SizedBox(
        height: 8 * 1,
      ),
      _placeDetailsResponse?.result?.website != null
          ? GestureDetector(
              onTap: () async {
                var uri =
                    Uri.parse(_placeDetailsResponse?.result?.website ?? "");
                var canLaunch = await canLaunchUrl(uri);
                if (canLaunch) {
                  await launchUrl(uri);
                }
              },
              child: Text(
                _placeDetailsResponse!.result!.website!,
                style: const TextStyle(color: Colors.blueAccent),
                softWrap: true,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
              ),
            )
          : Container(),
      const SizedBox(
        height: 8 * 2,
      ),
      widget.review != null
          ? Column(
              children: [
                Text(
                  "${widget.friendName?.isNotEmpty == true ? "${widget.friendName}'s" : "My"} Review",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                RatingBar.builder(
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (_) {},
                  allowHalfRating: true,
                  initialRating: widget.review!.rating,
                ),
                Text("${widget.review!.rating}/5"),
              ],
            )
          : Container(),
      const SizedBox(
        height: 8 * 2,
      ),
      widget.review != null
          ? Center(
              child: Column(
                children: [
                  Text(
                    "${widget.friendName?.isNotEmpty == true ? "${widget.friendName}'s" : "My"} Review:",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Text(
                    widget.review!.summary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  widget.friendName?.isNotEmpty == true
                      ? buildReviewButton(context)
                      : Container(),
                  _reviewImages.isNotEmpty == true
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
                ],
              ),
            )
          : buildReviewButton(context),
      const SizedBox(
        height: 8 * 4,
      ),
      _placeDetailsResponse?.result?.reviews?.isNotEmpty == true
          ? Center(
              child: SizedBox(
                height: 200,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: _buildGoogleReviews(
                      _placeDetailsResponse!.result!.reviews!),
                ),
              ),
            )
          : Container(),
    ];
  }

  Center buildReviewButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          var future = showDialog(
            context: context,
            builder: (_) {
              return MyReviewDialog(
                area: widget.area,
                summary: widget.review?.summary,
              );
            },
          );

          future.then((value) {
            if (value.runtimeType == Review) {
              BlocProvider.of<FirebaseBloc>(context).add(
                GetReviewImages(widget.area.placeId, value),
              );
              setState(() {
                widget.review = value;
              });
            }
          });
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
              vertical: 8 * 2,
              horizontal: 8 * 8,
            ),
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
    );
  }

  List<Widget> _buildGoogleReviews(List<Reviews> reviews) {
    return reviews.map((review) {
      String limitedText =
          review.text ?? "It was pretty good, would recommend!";
      if (limitedText.length > 200) {
        limitedText = limitedText.substring(0, 200) + "...";
      }

      bool showFullText = false;

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    review.profilePhotoUrl != null
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(review.profilePhotoUrl!),
                          )
                        : Container(),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.authorName ?? "Ian Smith",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        RatingBar.builder(
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (_) {},
                          allowHalfRating: true,
                          initialRating: review.rating?.toDouble() ?? 3.0,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showFullText = true;
                      });
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Flexible(
                        child: Text(
                          showFullText == true
                              ? review.text ?? ""
                              : limitedText,
                          softWrap: true,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

class MyReviewDialog extends StatefulWidget {
  String? summary;
  NearbySearchResponseResult area;

  MyReviewDialog({super.key, required this.area, this.summary});

  @override
  State<MyReviewDialog> createState() => _MyReviewDialogState();
}

class _MyReviewDialogState extends State<MyReviewDialog> {
  var rating = 0.0;
  var summary = "";
  bool isValid = false;
  final ImagePicker picker = ImagePicker();
  List<ReviewImage> images = [];

  @override
  void initState() {
    super.initState();
    isValid = widget.summary?.isNotEmpty ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "My Review",
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
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
                    vertical: 8 * 4,
                    horizontal: 8 * 1,
                  ),
                ),
                onChanged: (text) {
                  setState(() {
                    summary = text;
                    isValid = summary.isNotEmpty;
                  });
                },
                maxLines: 3,
              ),
            ),
            GestureDetector(
              child: const Row(
                children: [
                  Icon(Icons.camera_alt),
                  Text("Take a photo"),
                ],
              ),
              onTap: () async {
                var image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  images.add(ReviewImage(image.path, image.name));
                }
              },
            ),
            const SizedBox(height: 8),
            GestureDetector(
              child: const Row(
                children: [
                  Icon(Icons.photo_album),
                  Text("Upload a photo"),
                ],
              ),
              onTap: () async {
                var image = await picker.pickImage(source: ImageSource.gallery);

                if (image != null) {
                  setState(() {
                    images.add(ReviewImage(image.path, image.name));
                  });
                }
              },
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                itemCount: images.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      File(images[index].path),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Cancel",
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (!isValid) {
              return;
            }
            var review = Review(rating, summary, widget.area, images);

            BlocProvider.of<FirebaseBloc>(context)
                .add(UserSubmittedReview(review));

            BlocProvider.of<MapBloc>(context)
                .add(UserSubmittedReviewLocally(review));

            Navigator.pop(context, review);
          },
          child: const Text(
            "Submit",
            textAlign: TextAlign.end,
            style: TextStyle(
              color: true ? Colors.blue : Colors.grey,
            ),
          ),
        )
      ],
    );
  }
}
