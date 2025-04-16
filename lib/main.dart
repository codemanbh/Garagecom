import 'package:flutter/material.dart';

// theme
import './theme/flutter_midnight_neon_theme.dart';

// packages
import 'package:flutter_dotenv/flutter_dotenv.dart';

// providers
import 'package:garagecom/providers/NavProvider.dart';
import 'package:garagecom/providers/SettingsProvider.dart';
import 'package:provider/provider.dart';
// pages
import './pages/LoginPage.dart';
import './pages/SignupPage.dart';
import './pages/HomePage.dart';
import './pages/AccountSettingsPage.dart';
import './pages/ServicePage.dart';
import './pages/SettingsPage.dart';
import './pages/CreatePostPage.dart';
import './pages/TestPage.dart';
import './pages/CameraPage.dart';
import './pages/AddPartPage.dart';

void main() async {
  await dotenv.load(fileName: 'assets/.env'); // loud the env variables

  // list of providers
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ChangeNotifierProvider(create: (_) => NavProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: FlutterMidnightNeonTheme.lightTheme,
        darkTheme: FlutterMidnightNeonTheme.darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        // home: const MyHomePage(title: 'Flutter Demo Home Page'),

        initialRoute: '/loginPage',
        routes: {
          '/loginPage': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/homePage': (context) => const HomePage(),
          '/profilePage': (context) => const AccountSettingsPage(),
          '/servicePage': (context) => const ServicePage(),
          '/settingsPage': (context) => const SettingsPage(),
          '/createPostPage': (context) => const CreatePostPage(),
          '/testPage': (context) => const TestPage(),
          '/aiPage': (context) => CameraPage(),
          '/AddPartPage': (context) => const AddPartPage(),
          '/AccountSettingsPage': (context) => const AccountSettingsPage(),
          
        });
  }
}
