import 'dart:convert';
import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mealmapper/firebase_options.dart';
import 'package:mealmapper/models/review.dart';

part 'firebase_event.dart';
part 'firebase_state.dart';

class FirebaseBloc extends Bloc<FirebaseEvent, FirebaseState> {
  FirebaseBloc() : super(FirebaseInitial()) {
    on<UserSubmittedReview>(_onUserSubmittedReview);
    on<GetUserPinsOnLoad>(_onGetUserPinsOnLoad);
  }

  Future<void> _onUserSubmittedReview(
    UserSubmittedReview event,
    Emitter<FirebaseState> emit,
  ) async {
    final storage = FirebaseStorage.instance
        .ref()
        .child("TestUser")
        .child("${event._review.area.placeId}.json");
    try {
      var reviewJson = jsonEncode(event._review.toJson());
      await storage.putString(reviewJson);
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
      for (var i = 0; i < userData.items.length; i++) {
        var fullPath = userData.items[i].fullPath;
        var data = await storage.parent?.child(fullPath).getData();
        if (data?.toList() == null) {
          emit(FirebaseGenericFailure());
          return;
        }
        var review = Review.fromJson(jsonDecode(utf8.decode(data!.toList())));
        reviews.add(review);
      }

      emit(FetchedUserSavedPins(reviews));
    } catch (e) {
      print(e);
      emit(FirebaseGenericFailure());
    }
  }
}
