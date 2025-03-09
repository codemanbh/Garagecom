import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(
              () => isLastPage = index == 2); // Change based on number of pages
        },
        children: [
          buildPage("Welcome!", "This is an awesome app.", Colors.blue),
          buildPage(
              "Explore Features", "Discover amazing tools.", Colors.green),
          buildPage("Get Started", "Enjoy using the app!", Colors.purple),
        ],
      ),
      bottomSheet: isLastPage
          ? TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool("onboardingShown", true);
                Navigator.pushReplacementNamed(context, "/home");
              },
              child: Text("Get Started"),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _controller.jumpToPage(2),
                  child: Text("Skip"),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () => _controller.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildPage(String title, String subtitle, Color color) {
    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 10),
            Text(subtitle, style: TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
