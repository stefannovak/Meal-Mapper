part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();
}

class MapInitial extends MapState {
  @override
  List<Object> get props => [];
}

class LocationUnavailable extends MapInitial {
  @override
  List<Object> get props => [];
}

class LocationDenied extends MapInitial {
  @override
  List<Object> get props => [];
}

class LocationPermanentlyDenied extends MapInitial {
  @override
  List<Object> get props => [];
}

class FetchedLocation extends MapInitial {
  late double latitude;
  late double longitude;

  FetchedLocation(this.latitude, this.longitude);

  @override
  List<Object> get props => [];
}

class FetchedNearbyArea extends MapInitial {
  late NearbySearchResponse nearbySearchResponse;

  FetchedNearbyArea(this.nearbySearchResponse);

  @override
  List<Object> get props => [];
}

class FetchedPlaceDetails extends MapInitial {
  late PlaceDetailsResponse response;

  FetchedPlaceDetails(this.response);

  @override
  List<Object> get props => [];
}

class UpdateMapWithNewReview extends MapInitial {
  late Review review;

  UpdateMapWithNewReview(this.review);

  @override
  List<Object> get props => [review];
}

class FetchedSearchResponse extends MapInitial {
  late GoogleTextSearchResponse response;

  FetchedSearchResponse(this.response);

  @override
  List<Object> get props => [response];
}
