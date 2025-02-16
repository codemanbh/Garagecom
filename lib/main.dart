import 'package:flutter/material.dart';
// themes
// import 'package:garagecom/flutter_custom_themes_vol1/flutter_midnight_neon_theme.dart';
// import './flutter_custom_themes_vol1/flutter_monokai_theme.dart';
import './theme/flutter_midnight_neon_theme.dart';
import './theme/flutter_monokai_theme.dart';
// providers
import 'package:garagecom/providers/NavProvider.dart';
import 'package:garagecom/providers/SettingsProvider.dart';
import 'package:provider/provider.dart';
// pages
import './pages/LoginPage.dart';
import './pages/HomePage.dart';
import './pages/ProfilePage.dart';
import './pages/ServicePage.dart';
import './pages/SettingsPage.dart';
import './pages/CreatePostPage.dart';
import './pages/TestPage.dart';
import './pages/CameraPage.dart';

void main() {
  // list of providers
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ChangeNotifierProvider(create: (_) => NavProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: FluttterMidnightNeonTheme.lightTheme,
        darkTheme: FluttterMidnightNeonTheme.darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        // home: const MyHomePage(title: 'Flutter Demo Home Page'),
        initialRoute: '/loginPage',
        routes: {
          '/loginPage': (context) => LoginPage(),
          '/homePage': (context) => HomePage(),
          '/profilePage': (context) => ProfilePage(),
          '/servicePage': (context) => ServicePage(),
          '/settingsPage': (context) => SettingsPage(),
          '/createPostPage': (context) => CreatePostPage(),
          '/testPage': (context) => TestPage(),
          '/aiPage': (context) => CameraPage()
        });
  }
}
