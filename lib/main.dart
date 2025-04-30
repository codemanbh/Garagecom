import 'package:flutter/material.dart';

// theme
import './theme/flutter_midnight_neon_theme.dart';

// packages
import 'package:flutter_dotenv/flutter_dotenv.dart';

// firebase
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'firebase_options.dart';

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
import './pages/MainPage.dart';
import './pages/CommentPage.dart';
import './pages/AddAndEditCars.dart';

// Helpers
import './helpers/navigationHeper.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: 'assets/.env'); // loud the env variables
  // print(dotenv.env);
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: FlutterMidnightNeonTheme.lightTheme,
      darkTheme: FlutterMidnightNeonTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: '/mainPage',
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
        '/mainPage': (context) => const MainPage(),
        '/commentPage': (context) => CommentPage(
              postID: ModalRoute.of(context)!.settings.arguments as int? ?? 0,
              postTitle: '',
              questionBody: '',
              initialVotes: 0,
            ),
        '/addAndEditCarsPage': (context) => AddAndEditCars()
      },
    );
  }
}

// Example usage of the suggested code change
void navigateToCommentPage(BuildContext context, int postId) {
  Navigator.pushNamed(context, '/commentPage',
      arguments: postId // The ID of the post to show comments for
      );
}
