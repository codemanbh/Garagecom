import 'package:flutter/material.dart';
import './../providers/NavProvider.dart';
import 'package:provider/provider.dart';
import '../models/User.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.design_services),
      label: 'Service',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.photo_camera),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.forum),
      label: 'Community',
    ),

    // BottomNavigationBarItem(
    //   icon: Icon(Icons.add),
    //   label: 'Create',
    // ),

    BottomNavigationBarItem(
      icon: Icon(Icons.account_circle),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (User.role == 'Admin') {
      items.add(BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings),
        label: 'Admin',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = context.watch<NavProvider>().pageIndex;

    return BottomNavigationBar(
      currentIndex: pageIndex,
      onTap: (index) {
        Provider.of<NavProvider>(context, listen: false).navToPage(index);
      },
      items: items,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Colors.grey,
    );
  }
}
