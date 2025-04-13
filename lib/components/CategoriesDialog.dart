import 'package:flutter/material.dart';
import './CategoriesSection.dart';

Future<void> showCategoriesDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select categories'),
        content: SingleChildScrollView(
          child: CategoriesSection(),
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                // do the confermation backend logic
                Navigator.of(context).pop();
              },
              child: Text('Confirm'))
        ],
      );
    },
  );
}

// class CategoriesDialog extends StatefulWidget {
//   const CategoriesDialog({super.key});

//   @override
//   State<CategoriesDialog> createState() => _CategoriesDialogState();
// }

// class _CategoriesDialogState extends State<CategoriesDialog> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }