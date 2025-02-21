import 'package:flutter/material.dart';
import '../models/Post.dart';
import '../pages/CommentPage.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  const PostCard({
    required this.post,
    required this.onUpvote,
    required this.onDownvote,
  });

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

  void navigateToCommentPage(
      BuildContext context, String title, String? imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentPage(
          postTitle: title,
          questionBody:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat.',
          initialVotes: post.numOfVotes,
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // if (post.imageUrl != null) // Display image if URL is provided
          //   Image.network(
          //     post.imageUrl!,
          //     width: double.infinity,
          //     height: 150,
          //     fit: BoxFit.cover,
          //   ),
          ListTile(
            title: Text(post.title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: widget.onUpvote,
                  icon: const Icon(Icons.arrow_upward),
                ),
                Text(post.numOfVotes.toString()),
                IconButton(
                  onPressed: widget.onDownvote,
                  icon: const Icon(Icons.arrow_downward),
                ),
              ],
            ),
            onTap: () =>
                navigateToCommentPage(context, post.title, post.imageUrl),
          ),
        ],
      ),
    );
  }
}
