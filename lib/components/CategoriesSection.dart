import 'package:flutter/material.dart';
import '../managers/CategoriesManager.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  List<bool> isSelectedList =
      CategoriesManager.categories.map<bool>((c) => false).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Wrap(
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
