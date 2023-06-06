import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:mealmapper/firebase_options.dart';
import 'package:mealmapper/models/google/nearby_search_response.dart';
import 'package:mealmapper/models/review.dart';
import 'package:mealmapper/screens/profile_screen.dart';

part 'firebase_event.dart';
part 'firebase_state.dart';

class FirebaseBloc extends Bloc<FirebaseEvent, FirebaseState> {
  final FirebaseAuth auth;

  FirebaseBloc({required this.auth}) : super(FirebaseInitial()) {
    on<UserSubmittedReview>(_onUserSubmittedReview);
    on<GetUserPinsOnLoad>(_onGetUserPinsOnLoad);
    on<GetReviewImages>(_onGetReviewImages);
    on<UserSentFriendRequest>(_onUserSentFriendRequest);
  }

  Future<void> _onUserSubmittedReview(
    UserSubmittedReview event,
    Emitter<FirebaseState> emit,
  ) async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(UnauthenticatedUserError());
      return;
    }

    final storage = FirebaseStorage.instance
        .ref()
        .child(userId)
        .child(event._review.area.placeId);

    final jsonStorage = storage.child("${event._review.area.placeId}.json");

    try {
      var reviewJson = jsonEncode(event._review.toJson());
      var jsonResult = await jsonStorage.putString(reviewJson);
      if (jsonResult.state == TaskState.success) {
        for (var image in event._review.images) {
          var file = File(image.path);
          var imageStorage = storage.child(image.name);
          var imageResult = await imageStorage.putFile(file);
          if (imageResult.state == TaskState.error) {
            print("failed uploading image");
            emit(FirebaseGenericFailure());
          }
        }
      }

      emit(FirebaseGenericSuccess());
    } catch (e) {
      print(e);
      emit(FirebaseGenericFailure());
    }
  }

  Future<void> _onGetUserPinsOnLoad(
    GetUserPinsOnLoad event,
    Emitter<FirebaseState> emit,
  ) async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(UnauthenticatedUserError());
      return;
    }

    final storage = FirebaseStorage.instance.ref().child(userId);
    try {
      var userData = await storage.listAll();
      List<Review> reviews = [];
      for (var reference in userData.prefixes) {
        var placeStorage = storage.child(reference.name);
        var jsonDataReference = placeStorage.child("${reference.name}.json");
        var reviewData = await jsonDataReference.getData();
        if (reviewData?.toList() == null) {
          emit(FirebaseGenericFailure());
          return;
        }

        var review =
            Review.fromJson(jsonDecode(utf8.decode(reviewData!.toList())));
        reviews.add(review);
      }

      emit(FetchedUserSavedPins(reviews));
    } catch (e) {
      print(e);
      emit(FirebaseGenericFailure());
    }
  }

  Future<void> _onGetReviewImages(
    GetReviewImages event,
    Emitter<FirebaseState> emit,
  ) async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(UnauthenticatedUserError());
      return;
    }

    final storage =
        FirebaseStorage.instance.ref().child(userId).child(event.placeId);

    List<Uint8List> imagesMemory = [];
    for (var imageData in event.review.images) {
      try {
        var data = await storage.child(imageData.name).getData();
        if (data != null) {
          imagesMemory.add(data);
        }
      } catch (e) {
        emit(FirebaseGenericFailure());
        return;
      }
    }

    emit(FetchedReviewImages(imagesMemory));
  }

  Future<void> _onUserSentFriendRequest(
    UserSentFriendRequest event,
    Emitter<FirebaseState> emit,
  ) async {
    emit(FirebaseGenericSuccess());
  }
}
