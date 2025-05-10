import 'package:flutter/material.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    var token = prefs.getString('token');
    final response = await ApiHelper.getWithFullResponse(
        "api/Registration/ValidateUser", {"token": token});
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
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
