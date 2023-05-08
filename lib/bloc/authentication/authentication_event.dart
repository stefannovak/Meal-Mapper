part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class UserCreatedAccount extends AuthenticationEvent {
  late String email;
  late String password;

  UserCreatedAccount(this.email, this.password);

  @override
  List<Object> get props => [];
}

class UserLoggedIn extends AuthenticationEvent {
  late String email;
  late String password;

  UserLoggedIn(this.email, this.password);

  @override
  List<Object> get props => [];
}

class UserSignedOut extends AuthenticationEvent {}

class UserDeletedAccount extends AuthenticationEvent {}
