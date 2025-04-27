import 'package:flutter/material.dart';
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
      HomePage(),
      ServicePage(),
      CreatePostPage(),
      CameraPage(),
      AccountSettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: pages,
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
