import 'package:flutter/material.dart';
import '../components/CustomNavBar.dart';
import '../components/PostCard.dart';
import '../models/Post.dart';
import '../managers/PostsManager.dart';
import '../managers/PostsManager.dart';
import '../components/PostWidget.dart';
import '../components/CategoriesSection.dart';
import '../searchDelegates/PostSearchDelegate.dart';
import '../components/CategoriesDialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    PostsManager pm = PostsManager();
  }

  List<Post> posts = PostsManager.posts;

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
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: PostSearchDelegate(PostsManager.posts),
                );
              },
              icon: Icon(Icons.search))
        ],
        title: const Text('Home'),
      ),
      bottomNavigationBar: const CustomNavBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: posts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ElevatedButton(
                      onPressed: () async {
                        await showCategoriesDialog(context);
                      },
                      child: Text('Select categories'));
                } else {
                  final post = posts[index - 1];
                  return PostWidget(
                    accountId: post.accountId,
                    accountName: post.autherUsername,
                    postTitle: post.title,
                    postContent: post.description,
                    numOfVotes: post.numOfVotes,
                    postId: post.postID,
                    upvote: () => upvote(index),
                    downvote: () => downvote(index),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
