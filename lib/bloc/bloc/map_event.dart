part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class UserClickedMap extends MapEvent {
  late double _latitude;
  late double _longitude;

  UserClickedMap(latitude, longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }
}
