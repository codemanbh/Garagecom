import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../components/CommentCard.dart';
import '../models/Comment.dart';
import '../managers/CommentsManager.dart';

class CommentPage extends StatefulWidget {
  final String postTitle;
  final String questionBody;
  final int initialVotes;
  final String? imageUrl;
  final int postID; // Add post ID to fetch related comments

  const CommentPage({
    super.key,
    required this.postTitle,
    required this.questionBody,
    required this.initialVotes,
    this.imageUrl,
    required this.postID,
  });

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  // Track separate upvotes and downvotes for the post
  int postUpvotes = 0;
  int postDownvotes = 0;
  int postVotes = 0;
  String? imageUrl = '';
  
  List<Comment> comments = [];
  bool _isLoading = true;
  
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize post votes
    postVotes = widget.initialVotes;
    if (postVotes > 0) {
      postUpvotes = postVotes;
      postDownvotes = 0;
    } else if (postVotes < 0) {
      postUpvotes = 0;
      postDownvotes = -postVotes;
    } else {
      postUpvotes = 0;
      postDownvotes = 0;
    }
    imageUrl = widget.imageUrl;
    
    // Load comments when the page initializes
    _loadComments();
  }
  
  // Function to load comments from the database
  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await CommentsManager.fetchComments(widget.postID);
      
      if (success) {
        setState(() {
          comments = List.from(CommentsManager.comments); // Create a copy
          _isLoading = false;
        });
        
        print('Loaded ${comments.length} comments for post ${widget.postID}');
      } else {
        setState(() {
          comments = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load comments'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      print('Error loading comments: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void upvotePost() {
    setState(() {
      postUpvotes++;
      postVotes = postUpvotes - postDownvotes;
    });
  }

  void downvotePost() {
    setState(() {
      postDownvotes++;
      postVotes = postUpvotes - postDownvotes;
    });
  }

  void upvoteComment(Comment comment) {
    setState(() {
      comment.upvotes++;
    });
  }

  void downvoteComment(Comment comment) {
    setState(() {
      comment.downvotes++;
    });
  }

  // Add a comment to the database
  Future<void> addComment() async {
    final newCommentText = commentController.text.trim();
    if (newCommentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment cannot be empty'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    // Show loading state
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await CommentsManager.addComment(widget.postID, newCommentText);
      
      if (success) {
        // Refresh comments from server
        setState(() {
          comments = List.from(CommentsManager.comments);
          commentController.clear();
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment added successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      print('Error adding comment: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _sharePost() async {
    final String postContent = 
        "Check out this discussion from GarageCom:\n\n"
        "${widget.postTitle}\n\n"
        "${widget.questionBody}\n\n"
        "Join the conversation with ${comments.length} comments!";
    
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
        subject: widget.postTitle,
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

  Widget buildPostHeader(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      color: colorScheme.surface,
      shadowColor: colorScheme.primary.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                widget.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: colorScheme.surfaceVariant,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 40,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image could not be loaded',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Author',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Posted 2 days ago',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.postTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    widget.questionBody,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: upvotePost,
                      icon: Icon(
                        Icons.arrow_upward_rounded,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                      tooltip: 'Upvote',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: postVotes > 0 
                          ? colorScheme.primary.withOpacity(0.1)
                          : postVotes < 0
                            ? colorScheme.error.withOpacity(0.1)
                            : colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: postVotes > 0 
                            ? colorScheme.primary.withOpacity(0.5)
                            : postVotes < 0
                              ? colorScheme.error.withOpacity(0.5)
                              : colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        postVotes.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: postVotes > 0
                            ? colorScheme.primary
                            : postVotes < 0
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: downvotePost,
                      icon: Icon(
                        Icons.arrow_downward_rounded,
                        color: colorScheme.error,
                        size: 28,
                      ),
                      tooltip: 'Downvote',
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _sharePost,
                      icon: Icon(
                        Icons.share_outlined,
                        size: 25,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      tooltip: 'Share',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Discussion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort comments',
            onPressed: () {
              // Show sort options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadComments,
              color: colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildPostHeader(theme, colorScheme),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.comment,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Comments',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${comments.length}',
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _loadComments,
                              icon: Icon(
                                Icons.refresh,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              label: Text(
                                'Refresh',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                          ),
                        )
                      else if (comments.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.comment_outlined,
                                    size: 40,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No comments yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to comment on this post',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                  },
                                  icon: Icon(
                                    Icons.add_comment,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                  label: Text(
                                    'Add Comment',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
                                    side: BorderSide(color: colorScheme.primary),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return CommentCard(
                              username: comment.getUsernameDisplay(),
                              content: comment.text,
                              timeAgo: comment.getFormattedDate(),
                              upvotes: comment.upvotes,
                              downvotes: comment.downvotes,
                              onUpvote: () => upvoteComment(comment),
                              onDownvote: () => downvoteComment(comment),
                              onReply: () {
                                // Reply functionality
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    'Y',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: TextFormField(
                      controller: commentController,
                      maxLines: null,
                      minLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isLoading 
                  ? Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: colorScheme.primary,
                      ),
                    )
                  : FloatingActionButton.small(
                      onPressed: addComment,
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        size: 20,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
