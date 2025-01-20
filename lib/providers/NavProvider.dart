import 'package:flutter/material.dart';

class NavProvider with ChangeNotifier {
  int _pageIndex = 0;
  int get pageIndex => _pageIndex;

  void navToPage(int index) {
    _pageIndex = index;
  }
}
