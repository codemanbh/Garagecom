import 'package:flutter/material.dart';
import '../models/Post.dart';

class Userprovider with ChangeNotifier {
  int? userID;
  bool isLoggedIn = false;
  String? userName;
  String? email;
  List<Post> posts = [];
  bool isMyAccount = false;

  void login() {}
  void logout() {}
  void signup() {}
}
