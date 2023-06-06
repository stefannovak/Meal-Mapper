import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mealmapper/models/friend_reviews.dart';
import 'package:mealmapper/models/google/google_text_search_response.dart';
import 'package:mealmapper/models/google/nearby_search_response.dart'
    as NearbySearchResponse;
import 'package:mealmapper/models/google/place_details_response.dart';
import 'package:mealmapper/models/review.dart';
import 'package:mealmapper/screens/profile_screen.dart';
import 'package:mealmapper/services/api_service.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  late ApiService _apiService;

  MapBloc(ApiService apiService) : super(MapInitial()) {
    _apiService = apiService;

    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<UserClickedMap>(_onUserClickedMap);
    on<GetLocalPlaces>(_onGetLocalPlaces);
    on<FetchPlaceDetails>(_onFetchPlaceDetails);
    on<UserSubmittedReviewLocally>(_onUserSubmittedReviewLocally);
    on<UserSearchedLocation>(_onUserSearchedLocation);
    on<GetFriendReviews>(_onGetFriendReviews);
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<MapState> emit,
  ) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      emit(LocationUnavailable());
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        emit(LocationDenied());
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      emit(LocationPermanentlyDenied());
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var position = await Geolocator.getCurrentPosition();
    var deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      if (!iosInfo.isPhysicalDevice) {
        // Manchester
        emit(FetchedLocation(53.4808, -2.2426));
        return;
      }
    }
    emit(FetchedLocation(position.latitude, position.longitude));
    // var response = await _apiService.getGoogleNearbySearch(
    //   position.latitude,
    //   position.longitude,
    //   radius: 800,
    // );

    // if (response.isSuccess && response.success != null) {
    //   emit(FetchedNearbyArea(response.success!));
    // }
  }

  Future<void> _onUserClickedMap(
    UserClickedMap event,
    Emitter<MapState> emit,
  ) async {
    final response = await _apiService.getGoogleNearbySearch(
      event._latitude,
      event._longitude,
    );

    if (response.isSuccess &&
        response.success != null &&
        response.success?.results?.isNotEmpty == true) {
      emit(FetchedNearbyArea(response.success!));
      return;
    }

    print("getGoogleNearbySearch was empty");
  }

  Future<void> _onGetLocalPlaces(
    GetLocalPlaces event,
    Emitter<MapState> emit,
  ) async {
    final response = await _apiService.getGoogleNearbySearch(
      event._latitude,
      event._longitude,
      radius: 800,
      // radius: 100,
    );

    if (response.isSuccess && response.success != null) {
      emit(FetchedNearbyArea(response.success!));
    }
  }

  Future<void> _onFetchPlaceDetails(
    FetchPlaceDetails event,
    Emitter<MapState> emit,
  ) async {
    final response = await _apiService.getPlaceDetails(
      event._placeId,
    );

    if (response.isSuccess && response.success != null) {
      emit(FetchedPlaceDetails(response.success!));
    }
  }

  Future<void> _onUserSubmittedReviewLocally(
    UserSubmittedReviewLocally event,
    Emitter<MapState> emit,
  ) async {
    emit(UpdateMapWithNewReview(event.review));
  }

  Future<void> _onUserSearchedLocation(
    UserSearchedLocation event,
    Emitter<MapState> emit,
  ) async {
    var response = await _apiService.googleTextSearch(
      event.query,
      event.latitude,
      event.longitude,
    );

    if (response.isSuccess &&
        response.success != null &&
        response.success?.results?.isNotEmpty == true) {
      emit(FetchedSearchResponse(response.success!));
    }
  }

  Future<void> _onGetFriendReviews(
    GetFriendReviews event,
    Emitter<MapState> emit,
  ) async {
    if (hasSharedJoeReviews) {
      var joeReviews = <Review>[];
      joeReviews.add(
        Review(
          3.5,
          "Not that great, dry chicken.",
          NearbySearchResponse.NearbySearchResponseResult(
            placeId: "ChIJQ7AC_Oaxe0gRab0Qb9UBehA",
            geometry: NearbySearchResponse.Geometry(
              location: NearbySearchResponse.Location(
                lat: 53.47420509999999,
                lng: -2.2551638,
              ),
            ),
            name: "Dukes 92",
            rating: 4.2,
            vicinity: "18 - 25 Castle Street, Manchester",
          ),
          [],
        ),
      );

      joeReviews.add(
        Review(
          4.5,
          "Delicious. Try the sushi.",
          NearbySearchResponse.NearbySearchResponseResult(
            placeId: "ChIJiZERb-exe0gRT_t-z0KOJxk",
            geometry: NearbySearchResponse.Geometry(
              location: NearbySearchResponse.Location(
                lat: 53.4765598,
                lng: -2.2557022,
              ),
            ),
            name: "Sapporo Teppanyaki Manchester",
            rating: 4.5,
            vicinity: "91-93 Liverpool Road, Manchester",
          ),
          [],
        ),
      );
      emit(FetchedFriendReviews(FriendReviews(joeReviews, "Joe")));
    }

    if (hasSharedSamReviews) {
      var samReviews = <Review>[];
      samReviews.add(
        Review(
          3.0,
          "Pretty average, not worth the price.",
          NearbySearchResponse.NearbySearchResponseResult(
            placeId: "ChIJiZERb-exe0gRT_t-z0KOJxk",
            geometry: NearbySearchResponse.Geometry(
              location: NearbySearchResponse.Location(
                lat: 53.4796873,
                lng: -2.2532964,
              ),
            ),
            name: "Tattu",
            rating: 4.4,
            vicinity: "3 Hardman Square, Gartside Street, Manchester",
          ),
          [],
        ),
      );

      emit(FetchedFriendReviews(FriendReviews(samReviews, "Sam")));
    }
  }
}
