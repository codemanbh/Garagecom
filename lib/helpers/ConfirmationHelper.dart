import 'package:flutter/material.dart';

class ConfirmationHelper {
  /// Shows a confirmation dialog with a required [title] and [action] callback.
  static Future<void> show({
    required BuildContext context,
    required String title,
    required VoidCallback action,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // close the dialog
              action(); // perform the action
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
