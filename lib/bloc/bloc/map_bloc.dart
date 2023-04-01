import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mealmapper/services/api_service.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  late ApiService _apiService;
  MapBloc(ApiService apiService) : super(MapInitial()) {
    _apiService = apiService;

    on<MapEvent>((event, emit) {
      on<UserClickedMap>(_onUserClickedMap);
    });
  }

  Future<void> _onUserClickedMap(
    UserClickedMap event,
    Emitter<MapState> emit,
  ) async {
    final response = await _apiService.getGoogleNearbySearch(
        event._latitude, event._longitude);

    if (response.isSuccess) {
      emit(FetchedPlaceDetails());
    }
  }
}
