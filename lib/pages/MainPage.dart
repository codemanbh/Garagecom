import 'package:flutter/material.dart';
import 'package:garagecom/pages/AdminPage.dart';
import './../providers/NavProvider.dart';
import 'package:provider/provider.dart';
import './HomePage.dart';
import './ServicePage.dart';
import './CreatePostPage.dart';
import './CameraPage.dart';
import './AccountSettingsPage.dart';
import '../components/CustomNavBar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageIndex = context.watch<NavProvider>().pageIndex;

    final List<Widget> pages = const [
      ServicePage(),
      CameraPage(),

      HomePage(),
      // CreatePostPage(),
      AccountSettingsPage(),
      AdminPage()
    ];

    return Scaffold(
      body: pages[pageIndex],
      bottomNavigationBar: const CustomNavBar(),
    );

    // return Scaffold(
    //   body: IndexedStack(
    //     index: pageIndex,
    //     children: pages,
    //   ),
    //   bottomNavigationBar: const CustomNavBar(),
    // );
  }
}
