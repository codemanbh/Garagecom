import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final String accountId;
  final String accountName;
  final String postTitle;
  final String postContent;
  final int numOfVotes;
  final String postId;
  final VoidCallback upvote;
  final VoidCallback downvote;

  const PostWidget({
    super.key,
    required this.accountId,
    required this.accountName,
    required this.postTitle,
    required this.postContent,
    required this.numOfVotes,
    required this.postId,
    required this.upvote,
    required this.downvote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Row
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primary.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                accountName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'Post #$postId',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Post Title
          Text(
            postTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          
          // Post Content
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.onSurfaceVariant.withOpacity(0.2),
              ),
            ),
            child: Text(
              postContent,
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Voting Row
          Row(
            children: [
              // Vote count display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  numOfVotes.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              // Vote buttons
              ElevatedButton.icon(
                onPressed: upvote,
                icon: Icon(Icons.thumb_up, size: 16),
                label: const Text('Upvote'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: downvote,
                icon: Icon(Icons.thumb_down, size: 16),
                label: const Text('Downvote'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceVariant,
                  foregroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
