part of 'firebase_bloc.dart';

abstract class FirebaseEvent extends Equatable {
  const FirebaseEvent();

  @override
  List<Object> get props => [];
}

class UserSubmittedReview extends FirebaseEvent {
  late Review _review;

  UserSubmittedReview(Review review) {
    _review = review;
  }
}

class GetUserPinsOnLoad extends FirebaseEvent {}
