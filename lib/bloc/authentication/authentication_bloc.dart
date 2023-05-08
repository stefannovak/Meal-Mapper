import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<UserCreatedAccount>(_onUserCreatedAccount);
    on<UserLoggedIn>(_onUserLoggedIn);
    on<UserSignedOut>(_onUserSignedOut);
    on<UserDeletedAccount>(_onUserDeletedAccount);
  }

  Future<void> _onUserCreatedAccount(
    UserCreatedAccount event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      emit(AuthenticationSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthenticationFailure());
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
      emit(AuthenticationFailure());
    }
  }

  Future<void> _onUserLoggedIn(
    UserLoggedIn event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      emit(AuthenticationSuccess());
    } catch (e) {
      print("auth error");
      emit(AuthenticationFailure());
    }
  }

  Future<void> _onUserSignedOut(
    UserSignedOut event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("auth error");
      emit(AuthenticationFailure());
    }
  }

  Future<void> _onUserDeletedAccount(
    UserDeletedAccount event,
    Emitter<AuthenticationState> emit,
  ) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(AuthenticationFailure());
      return;
    }

    try {
      await user.delete();

      List<String> paths = [];
      paths = await _deleteFolder(user.uid, paths);
      for (String path in paths) {
        await FirebaseStorage.instance.ref().child(path).delete();
      }
    } catch (e) {
      print("auth error");
      emit(AuthenticationFailure());
    }
  }

  static Future<List<String>> _deleteFolder(
      String folder, List<String> paths) async {
    ListResult list =
        await FirebaseStorage.instance.ref().child(folder).listAll();
    List<Reference> items = list.items;
    List<Reference> prefixes = list.prefixes;
    for (Reference item in items) {
      paths.add(item.fullPath);
    }
    for (Reference subfolder in prefixes) {
      paths = await _deleteFolder(subfolder.fullPath, paths);
    }
    return paths;
  }
}
