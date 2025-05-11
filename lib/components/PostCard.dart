import 'package:flutter/material.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'package:garagecom/managers/PostsManager.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../pages/CommentPage.dart';
import './PostActionsMenu.dart';
import './UserAvatar.dart';
import './../models/User.dart';

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
  late final bool isAdminView;

  @override
  void initState() {
    super.initState();
    isAdminView = widget.isAdminView;
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

    // Add error handling to check if post exists
    if (postIndex < 0 || postIndex >= PostsManager.posts.length) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "Post not available",
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ),
      );
    }

    BoxDecoration buildPressedStyle() {
      return BoxDecoration(
        shape: BoxShape.circle,
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

    void navigateToCommentPage(int postId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommentPage(postId: postId),
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
        onTap: () =>
            navigateToCommentPage(PostsManager.posts[postIndex].postID),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  UserAvatar(
                    autherId: PostsManager.posts[postIndex].autherId,
                    autherUsername:
                        PostsManager.posts[postIndex].autherUsername,
                  ),
                  SizedBox(width: 12),
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
                          PostsManager.posts[postIndex].createdIn ??
                              'Unknown date',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  !PostsManager.posts[postIndex].allowComments
                      ? Icon(Icons.lock)
                      : SizedBox(),
                  PostActionsMenu(
                    autherId: PostsManager.posts[postIndex].autherId,
                    itemId: PostsManager.posts[postIndex].postID,
                    isPost: true,
                    isComment: false,
                    isAdminView: isAdminView,
                  )
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
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                      "${ApiHelper.mainDomain}api/posts/GetPostAttachment?filename=${PostsManager.posts[postIndex].imageUrl!}",
                      headers: {"Authorization": User.token ?? ''},
                      fit: BoxFit.cover),
                ),
              ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Votes section
                  !isAdminView
                      ? Row(
                          children: [
                            _buildUpVote(),
                            Text(
                              PostsManager.posts[postIndex].numOfVotes
                                  .toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    PostsManager.posts[postIndex].numOfVotes > 0
                                        ? colorScheme.primary
                                        : PostsManager.posts[postIndex]
                                                    .numOfVotes <
                                                0
                                            ? colorScheme.error
                                            : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            _buildDownVote(),
                          ],
                        )
                      : const SizedBox.shrink(),

                  !isAdminView
                      ? TextButton.icon(
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
                        )
                      : const SizedBox.shrink(),

                  !isAdminView
                      ? IconButton(
                          onPressed: () => _sharePost(context),
                          icon: Icon(
                            Icons.share_outlined,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          tooltip: 'Share',
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
