import 'package:flutter/material.dart';
import 'package:garagecom/providers/NavProvider.dart';
import 'package:provider/provider.dart';


class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _selectedIndex = 0;

  // Define the routes corresponding to the navigation bar items
  final List<String> _routes = [
    '/homePage',
    '/servicePage',
    '/createPostPage',
        '/aiPage',
    '/AccountSettingsPage',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Provider.of<NavProvider>(context, listen: false).navToPage(index);
    Navigator.of(context).pushReplacementNamed(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: context.read<NavProvider>().pageIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.design_services),
          label: 'Service',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera),
          label: 'Dashbourd',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Account',
        ),
      ],
      selectedItemColor: ThemeData().secondaryHeaderColor,
      unselectedItemColor: Colors.grey,
    );
  }
}
