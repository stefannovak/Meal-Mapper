import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
    emit(FetchedLocation(position.latitude, position.longitude));
  }

  Future<void> _onUserClickedMap(
    UserClickedMap event,
    Emitter<MapState> emit,
  ) async {
    final response = await _apiService.getGoogleNearbySearch(
      event._latitude,
      event._longitude,
    );

    if (response.isSuccess) {
      emit(FetchedPlaceDetails());
    }
  }

  Future<void> _onGetLocalPlaces(
    GetLocalPlaces event,
    Emitter<MapState> emit,
  ) async {
    final response = await _apiService.getGoogleNearbySearch(
      event._latitude,
      event._longitude,
      radius: 500,
    );

    if (response.isSuccess) {
      emit(FetchedPlaceDetails());
    }
  }
}