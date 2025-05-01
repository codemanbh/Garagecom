import 'package:flutter/material.dart';

class NavProvider extends ChangeNotifier {
  int _pageIndex = 0;

  int get pageIndex => _pageIndex;

  void navToPage(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  void setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }
  void resetPageIndex() {
    _pageIndex = 0;
    notifyListeners();
  }
}
