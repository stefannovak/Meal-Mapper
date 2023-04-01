part of 'map_bloc.dart';

@immutable
abstract class MapState extends Equatable {
  const MapState();
}

class MapInitial extends MapState {
  @override
  List<Object> get props => [];
}

class FetchedPlaceDetails extends MapInitial {
  @override
  List<Object> get props => [];
}
