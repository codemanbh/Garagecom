import 'package:flutter/material.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'package:garagecom/managers/PostsManager.dart';
import 'package:share_plus/share_plus.dart';
import '../models/Post.dart';
import '../pages/CommentPage.dart';

class PostCard extends StatefulWidget {
  // final Post post;
  final int postIndex;
  final bool isAdminView;

  const PostCard({
    super.key,
    required this.postIndex,
    this.isAdminView = false, // Add this parameter
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int postIndex;

  @override
  void initState() {
    super.initState();
    postIndex = widget.postIndex;
  }

  // Share function to handle sharing post content
  void _sharePost(BuildContext context) async {
    final String postContent = "Check out this post from GarageCom:\n\n"
        "${PostsManager.posts[postIndex].title}\n\n"
        "${PostsManager.posts[postIndex].description}\n\n"
        "Posted by: ${PostsManager.posts[postIndex].autherUsername}"
        "https:\\\\garagcom.com\\posts\\${PostsManager.posts[postIndex].postID}";


    try {
      // Show loading indicator
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Preparing to share...'),
          duration: Duration(milliseconds: 500),
        ),
      );

      // Use the share_plus package to open the native share dialog
      await Share.share(
        postContent,
        subject: PostsManager.posts[postIndex].title,
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not share: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    BoxDecoration buildPressedStyle() {
      return BoxDecoration(
        shape: BoxShape.circle,
        // border: Border.all(
        //   color: Colors.grey, // Border color
        //   // width: 1.0,
        // ),
        color: const Color.fromARGB(42, 255, 255, 255), // Background color
      );
    }

    Widget _buildUpVote() {
      bool isUpVoted = PostsManager.posts[postIndex].voteValue == 1;

      return Container(
        decoration: isUpVoted ? buildPressedStyle() : BoxDecoration(),
        child: IconButton(
          onPressed: () async {
            await PostsManager.posts[postIndex].handleUpvote();
            setState(() {});
          },
          icon: Icon(Icons.arrow_upward_rounded,
              color: colorScheme.primary, size: 22),
          tooltip: 'Upvote',
        ),
      );
    }

    Widget _buildDownVote() {
      bool isDownVoted = PostsManager.posts[postIndex].voteValue == -1;
      return Container(
        decoration: isDownVoted ? buildPressedStyle() : BoxDecoration(),
        child: IconButton(
          onPressed: () async {
            await PostsManager.posts[postIndex].handleDownvote();
            setState(() {});
          },
          icon: Icon(
            Icons.arrow_downward_rounded,
            color: colorScheme.error,
            size: 22,
          ),
          tooltip: 'Downvote',
        ),
      );
    }

    void navigateToCommentPage(int pageIndex) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommentPage(postIndex: postIndex),
        ),
      );
    }

    // Check if image is non-empty and non-null
    final bool hasImage = PostsManager.posts[postIndex].imageUrl != null &&
        PostsManager.posts[postIndex].imageUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      color: colorScheme.surface,
      shadowColor: colorScheme.primary.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: () => navigateToCommentPage(postIndex),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      PostsManager.posts[postIndex].autherUsername.isNotEmpty
                          ? PostsManager.posts[postIndex].autherUsername[0]
                              .toUpperCase()
                          : "?",
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PostsManager.posts[postIndex].autherUsername,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                        PostsManager.posts[postIndex].createdIn ?? 'Unknown date', 
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () {
                      // Show post options
                    },
                  ),
                ],
              ),
            ),

            // Post title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                PostsManager.posts[postIndex].title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            // Post content
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, hasImage ? 12 : 16),
              child: Text(
                PostsManager.posts[postIndex].description,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Post image (only if available)
            if (hasImage)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.surfaceVariant,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ApiHelper.image(
                      PostsManager.posts[postIndex].imageUrl!,
                      "api/posts/GetPostAttachment"),
                  // Image.network(
                  //   post.imageUrl!,
                  //   fit: BoxFit.cover,
                  //   loadingBuilder: (context, child, loadingProgress) {
                  //     if (loadingProgress == null) return child;
                  //     return Center(
                  //       child: CircularProgressIndicator(
                  //         value: loadingProgress.expectedTotalBytes != null
                  //             ? loadingProgress.cumulativeBytesLoaded /
                  //                 loadingProgress.expectedTotalBytes!
                  //             : null,
                  //         color: colorScheme.primary,
                  //       ),
                  //     );
                  //   },
                  //   errorBuilder: (context, error, stackTrace) {
                  //     return Container(
                  //       alignment: Alignment.center,
                  //       color: colorScheme.surfaceVariant,
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Icon(
                  //             Icons.broken_image_rounded,
                  //             color:
                  //                 colorScheme.onSurfaceVariant.withOpacity(0.5),
                  //             size: 36,
                  //           ),
                  //           const SizedBox(height: 8),
                  //           Text(
                  //             "Image not available",
                  //             style: TextStyle(
                  //               color: colorScheme.onSurfaceVariant
                  //                   .withOpacity(0.7),
                  //               fontSize: 12,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     );
                  //   },
                  // ),
                ),
              ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Votes section
                  Row(
                    children: [
                      _buildUpVote(),
                      Text(
                        PostsManager.posts[postIndex].numOfVotes.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: PostsManager.posts[postIndex].numOfVotes > 0
                              ? colorScheme.primary
                              : PostsManager.posts[postIndex].numOfVotes < 0
                                  ? colorScheme.error
                                  : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      _buildDownVote(),
                    ],
                  ),

                  // Comment button
                  TextButton.icon(
                    onPressed: () => navigateToCommentPage(postIndex),
                    icon: Icon(
                      Icons.comment_outlined,
                      size: 20,
                      color: colorScheme.secondary,
                    ),
                    label: Text(
                      'Comments',
                      style: TextStyle(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),

                  // Share button with functionality
                  IconButton(
                    onPressed: () => _sharePost(context),
                    icon: Icon(
                      Icons.share_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Share',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
