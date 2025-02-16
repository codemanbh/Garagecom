import 'package:flutter/material.dart';
import '../components/CustomNavBar.dart';
import '../components/PostCard.dart';
import '../models/Post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> posts = Post.posts;

  void upvote(int index) {
    setState(() {
      posts[index].upVote();
    });
  }

  void downvote(int index) {
    setState(() {
      posts[index].downVote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      bottomNavigationBar: const CustomNavBar(),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            post: post,
            onUpvote: () => upvote(index),
            onDownvote: () => downvote(index),
          );
        },
      ),
    );
  }
}