import 'package:flutter/material.dart';

class CommentPage extends StatelessWidget {
  final String postTitle;
  final String questionBody;
  final int initialVotes;
  final String? imageUrl;

  const CommentPage({
    required this.postTitle,
    required this.questionBody,
    required this.initialVotes,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(postTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (imageUrl != null) // Display image if URL is provided
              Image.network(
                imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(questionBody),
            ),
            // Add other widgets for comments, etc.
          ],
        ),
      ),
    );
  }
}