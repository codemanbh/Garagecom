import 'package:flutter/material.dart';
import '../models/Post.dart';
import '../pages/CommentPage.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Post post;
  @override
  void initState() {
    super.initState();
    post = widget.post;
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
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(post.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: post.upVote,
              icon: const Icon(Icons.arrow_upward),
            ),
            Text(post.numOfVotes.toString()),
            IconButton(
              onPressed: post.downVote,
              icon: const Icon(Icons.arrow_downward),
            ),
          ],
        ),
        onTap: () => navigateToCommentPage(context, post.title),
      ),
    );
    ;
  }
}
