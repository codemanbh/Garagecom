import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/Post.dart';
import '../pages/CommentPage.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  const PostCard({
    super.key, 
    required this.post,
    required this.onUpvote,
    required this.onDownvote,
  });

  void navigateToCommentPage(
      BuildContext context, String title, String? imageUrl, String description, int votes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentPage(
          postTitle: title,
          questionBody: description,
          initialVotes: votes,
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  // Share function to handle sharing post content
  void _sharePost(BuildContext context) async {
    final String postContent = 
        "Check out this post from GarageCom:\n\n"
        "${post.title}\n\n"
        "${post.description}\n\n"
        "Posted by: ${post.autherUsername}";
    
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
        subject: post.title,
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
    
    // Check if image is non-empty and non-null
    final bool hasImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    
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
        onTap: () => navigateToCommentPage(
          context, 
          post.title, 
          post.imageUrl, 
          post.description,
          post.numOfVotes
        ),
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
                      post.autherUsername.isNotEmpty
                          ? post.autherUsername[0].toUpperCase()
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
                          post.autherUsername,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          post.getFormattedDate(), // Use the formatted date method
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

            // Category chip
            if (post.categoryName != null && post.categoryName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: colorScheme.secondaryContainer,
                  label: Text(
                    post.categoryName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),
            
            // Post title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.title,
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
                post.description,
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
                  child: Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / 
                                loadingProgress.expectedTotalBytes!
                              : null,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        alignment: Alignment.center,
                        color: colorScheme.surfaceVariant,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_rounded,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Image not available",
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
                      IconButton(
                        onPressed: onUpvote,
                        icon: Icon(
                          Icons.arrow_upward_rounded,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                        tooltip: 'Upvote',
                      ),
                      
                      Text(
                        post.numOfVotes.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: post.numOfVotes > 0
                            ? colorScheme.primary
                            : post.numOfVotes < 0
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        onPressed: onDownvote,
                        icon: Icon(
                          Icons.arrow_downward_rounded,
                          color: colorScheme.error,
                          size: 22,
                        ),
                        tooltip: 'Downvote',
                      ),
                    ],
                  ),
                  
                  // Comment button
                  TextButton.icon(
                    onPressed: () => navigateToCommentPage(
                      context, 
                      post.title, 
                      post.imageUrl, 
                      post.description,
                      post.numOfVotes
                    ),
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