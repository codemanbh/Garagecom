import 'package:flutter/material.dart';
import '../models/Api.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
          onPressed: () {
            Api api = Api();
            api.testCookies();
          },
          child: Text('req')),
    );
  }
}
