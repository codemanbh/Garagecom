import 'package:flutter/material.dart';
import './../providers/NavProvider.dart';
import 'package:provider/provider.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final pageIndex = context.watch<NavProvider>().pageIndex;

    return BottomNavigationBar(
      currentIndex: pageIndex,
      onTap: (index) {
        Provider.of<NavProvider>(context, listen: false).navToPage(index);
      },
      items: const [
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
      ],
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Colors.grey,
    );
  }
}
