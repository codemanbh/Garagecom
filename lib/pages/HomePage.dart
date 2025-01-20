import 'package:flutter/material.dart';
import '../components/CustomNavBar.dart';
import './CommentPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> posts = [
    {
      'title': "Toyota Corolla 2020: Why won't my car start suddenly?",
      'votes': 4,
      'id': 1
    },
    {
      'title': 'Honda Civic 2018: How to fix overheating engine issue?',
      'votes': 3,
      'id': 2
    },
    {
      'title': 'Ford Mustang 2021: Why is my brake pedal stiff?',
      'votes': 5,
      'id': 3
    },
  ];

  void upvote(int index) {
    setState(() {
      posts[index]['votes']++;
    });
  }

  void downvote(int index) {
    setState(() {
      posts[index]['votes']--;
    });
  }

  void navigateToCommentPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentPage(
            postTitle: title,
            questionBody:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat.',
            initialVotes: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      bottomNavigationBar: CustomNavBar(),
      body: Expanded(
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(post['title']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => upvote(index),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    Text('${post['votes']}'),
                    IconButton(
                      onPressed: () => downvote(index),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                  ],
                ),
                onTap: () => navigateToCommentPage(context, post['title']),
              ),
            );
          },
        ),
      ),
    );
  }
}
