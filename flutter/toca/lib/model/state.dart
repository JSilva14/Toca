import 'package:firebase_auth/firebase_auth.dart';

class StateModel {
  bool isLoading;
  FirebaseUser user;
  List<String> favorites;
  double balance;

  StateModel({
    this.isLoading = false,
    this.user,
  });
}