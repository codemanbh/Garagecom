import 'package:flutter/material.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'package:garagecom/pages/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';
import 'MainPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defer initialization until after the first frame is rendered:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? '';
    int userId = prefs.getInt("userId") ?? 0;
    User.role = prefs.getString('role');

    final response = await ApiHelper.getWithFullResponse(
        "api/Registration/ValidateUser", {"token": token});

    if (token != null && token != '') {
      User.token = token;
      User.userId = userId;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }

    // await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo-raw-purple.png',
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 32),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
