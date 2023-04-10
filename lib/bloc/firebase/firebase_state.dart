part of 'firebase_bloc.dart';

abstract class FirebaseState extends Equatable {
  const FirebaseState();

  @override
  List<Object> get props => [];
}

class FirebaseInitial extends FirebaseState {
  @override
  List<Object> get props => [];
}

class FirebaseGenericSuccess extends FirebaseInitial {}

class FirebaseGenericFailure extends FirebaseInitial {}

class FetchedUserSavedPins extends FirebaseInitial {
  late List<Review> reviews;

  FetchedUserSavedPins(this.reviews);

  @override
  List<Object> get props => [reviews];
}

class FetchedReviewImages extends FirebaseInitial {
  late List<Uint8List> imagesMemory;

  FetchedReviewImages(this.imagesMemory);

  @override
  List<Object> get props => [imagesMemory];
}
