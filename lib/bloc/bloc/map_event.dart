part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class GetCurrentLocation extends MapEvent {
  const GetCurrentLocation();

  @override
  List<Object> get props => [];
}

class UserClickedMap extends MapEvent {
  late double _latitude;
  late double _longitude;

  UserClickedMap(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }
}

class GetLocalPlaces extends MapEvent {
  late double _latitude;
  late double _longitude;

  GetLocalPlaces(latitude, longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }
}

class FetchPlaceDetails extends MapEvent {
  late String _placeId;

  FetchPlaceDetails(placeId) {
    _placeId = placeId;
  }
}
