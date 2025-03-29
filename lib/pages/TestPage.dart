import 'package:flutter/material.dart';
import '../models/Api.dart';
import '../managers/CategoriesManager.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Page"),
      ),
      body: Wrap(
        spacing: 3.0, // Horizontal spacing between buttons
        runSpacing: 4.0, // Vertical spacing between lines
        children: CategoriesManager.categories
            .map((c) => ElevatedButton(onPressed: () {}, child: Text(c.title)))
            .toList(),
      ),
    );
  }
}
