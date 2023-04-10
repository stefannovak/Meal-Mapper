import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:mealmapper/firebase_options.dart';
import 'package:mealmapper/models/review.dart';

part 'firebase_event.dart';
part 'firebase_state.dart';

class FirebaseBloc extends Bloc<FirebaseEvent, FirebaseState> {
  FirebaseBloc() : super(FirebaseInitial()) {
    on<UserSubmittedReview>(_onUserSubmittedReview);
    on<GetUserPinsOnLoad>(_onGetUserPinsOnLoad);
    on<GetReviewImages>(_onGetReviewImages);
  }

  Future<void> _onUserSubmittedReview(
    UserSubmittedReview event,
    Emitter<FirebaseState> emit,
  ) async {
    final storage = FirebaseStorage.instance
        .ref()
        .child("TestUser")
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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final storage = FirebaseStorage.instance.ref().child("TestUser");
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

        // var review =
        //     Review.fromJson(jsonDecode(utf8.decode(reviewData!.toList())));
        // for (var image in review.images) {
        //   var photoData = await placeStorage.child(image.name).getData();
        // }

        // for (var i = 0; i < placeData.items.length; i++) {
        //   var fullPath = placeData.items[i].fullPath;
        //   var data = await storage.parent?.child(fullPath).getData();
        //   if (data?.toList() == null) {
        //     emit(FirebaseGenericFailure());
        //     return;
        //   }
        //   var review = Review.fromJson(jsonDecode(utf8.decode(data!.toList())));
        //   reviews.add(review);
        // }
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
    final storage =
        FirebaseStorage.instance.ref().child("TestUser").child(event.placeId);
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
}
