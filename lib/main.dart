import 'package:flutter/material.dart';
import 'package:garagecom/flutter_custom_themes_vol1/flutter_midnight_neon_theme.dart';
import './pages/LoginPage.dart';
import './pages/HomePage.dart';
import './pages/ProfilePage.dart';
import './pages/ServicePage.dart';
import './pages/SettingsPage.dart';
import './pages/CreatePostPage.dart';
import './flutter_custom_themes_vol1/flutter_monokai_theme.dart';

void main() {
  runApp(const MyApp());
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
        debugShowCheckedModeBanner: false,
        // home: const MyHomePage(title: 'Flutter Demo Home Page'),
        initialRoute: '/homePage',
        routes: {
          '/loginPage': (context) => LoginPage(),
          '/homePage': (context) => HomePage(),
          '/profilePage': (context) => ProfilePage(),
          '/servicePage': (context) => ServicePage(),
          '/settingsPage': (context) => SettingsPage(),
          '/createPostPage': (context) => CreatePostPage()
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
    );
  }
}
