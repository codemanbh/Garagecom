import 'package:flutter/material.dart';
import '../models/Post.dart';
import '../pages/CommentPage.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  const PostCard({super.key, 
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
          questionBody: post.description,
          initialVotes: post.numOfVotes,
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red,
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
            title: Row(
              children: [
                const CircleAvatar(backgroundColor: Colors.white, radius: 13),
                const SizedBox(
                  width: 10,
                ),
                Text(post.autherUsername ?? "asd"),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Text(post.description),
            ),
            trailing: Column(
              // mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

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
