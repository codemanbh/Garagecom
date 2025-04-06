import 'package:flutter/material.dart';
import '../models/Api.dart';
import '../managers/CategoriesManager.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<bool> isSelectedList =
      CategoriesManager.categories.map<bool>((c) => false).toList();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Page"),
      ),
      body:
          // ToggleButtons(
          //     borderRadius: BorderRadius.circular(100),
          //     borderWidth: 3,
          //     borderColor: const Color.fromARGB(195, 255, 255, 255),
          //     onPressed: (index) {},
          //     renderBorder: false,
          //     fillColor: Colors.transparent,
          //     isSelected: [
          //       false,
          //       true
          //     ],
          //     children: [
          //       Container(
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          //         child: Text(
          //           'Option 1',
          //           style: TextStyle(fontSize: 16),
          //         ),
          //       ),
          //       Container(
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          //         child: Text(
          //           'Option 2',
          //           style: TextStyle(fontSize: 16),
          //         ),
          //       ),
          //     ])
          // CategoriesManager.categories
          //     .map((c) => ElevatedButton(onPressed: () {}, child: Text(c.title)))
          //     .toList(),),
          Wrap(
        spacing: 3.0, // Horizontal spacing between buttons
        runSpacing: 4.0, // Vertical spacing between lines
        children: CategoriesManager.categories.asMap().entries.map(
          (c) {
            int index = c.key;

            return ElevatedButton(
              style: !isSelectedList[index]
                  ? ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(50, 255, 255, 255),
                      side: BorderSide(color: Colors.white, width: 2.0),
                    )
                  : ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      side: BorderSide(color: Colors.white, width: 2.0),
                    ),
              onPressed: () {
                isSelectedList[index] = !isSelectedList[index];
                setState(() {});
              },
              child: Text(
                c.value.title,
                style: !isSelectedList[index]
                    ? TextStyle(color: Colors.white)
                    : TextStyle(color: Colors.black),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
