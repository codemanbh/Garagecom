import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../components/CommentCard.dart';
import '../helpers/apiHelper.dart';
import '../models/Comment.dart';
import '../managers/CommentsManager.dart';
import '../models/Post.dart';
import '../components/PostActionsMenu.dart';
import './../components/UserAvatar.dart';

class CommentPage extends StatefulWidget {
  late final int postId;
  CommentPage({
    super.key,
    required this.postId,
  });

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  List<Comment> comments = [];
  Post post = Post(postID: -1, title: "", description: "", autherUsername: "", imageUrl: "", numOfVotes: 0, voteValue: 0, createdIn: "", categoryName: "", allowComments: true);
  bool _isLoading = true;


  final TextEditingController commentController = TextEditingController();

  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
    });

    print("PostID (FROM COMMENT PAGE): ${widget.postId}");

    var response = await ApiHelper.get(
      'api/Posts/GetPostByPostID',
      {'postId': widget.postId},
    );
    print('API Response received');
    print(response);
    if(response['succeeded'] == true) {
      var postData = response['parameters']['Post'];
      post = Post(
        postID: postData['postID'] ?? 0,
        title: postData['title'] ?? 'No Title',
        description: postData['description'] ?? 'No Content',
        autherUsername: postData['userName'] ?? '',
        imageUrl: postData['attachment'] != null && postData['attachment'].isNotEmpty
            ? postData['attachment']
            : null,
        numOfVotes: postData['countVotes'] ?? 0,
        voteValue: postData['voteValue'] ?? 0,
        createdIn: postData['createdIn'] ?? '',
        categoryName: postData['postCategory'] != null
            ? postData['postCategory']['title']
            : '',
        allowComments: true
      );
    }
    this.post = post;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await CommentsManager.fetchComments(
          widget.postId);

      if (success) {
        setState(() {
          comments = List.from(CommentsManager.comments);
          _isLoading = false;
        });

        print(
            'Loaded ${comments.length} comments for post ${post}');
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

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await CommentsManager.addComment(
          widget.postId, newCommentText);

      if (success) {
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
    final String postContent = "Check out this discussion from GarageCom:\n\n"
        "${post.title}\n\n"
        "${post.description}\n\n"
        "Join the conversation with ${comments.length} comments!";

    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Preparing to share...'),
          duration: Duration(milliseconds: 500),
        ),
      );

      await Share.share(
        postContent,
        subject: post.title,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not share: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  BoxDecoration buildPressedStyle() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: const Color.fromARGB(42, 255, 255, 255),
    );
  }

  Widget _buildUpVote() {
    bool isUpVoted = post.voteValue == 1;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: isUpVoted ? buildPressedStyle() : BoxDecoration(),
        child: IconButton(
          onPressed: () async {
            await post.handleUpvote();
            setState(() {});
          },
          icon: Icon(Icons.arrow_upward_rounded,
              color: Theme.of(context).colorScheme.primary, size: 22),
          tooltip: 'Upvote',
        ),
      ),
    );
  }

  Widget _buildDownVote() {
    bool isDownVoted = post.voteValue == -1;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: isDownVoted ? buildPressedStyle() : BoxDecoration(),
        child: IconButton(
          onPressed: () async {
            await post.handleDownvote();
            setState(() {});
          },
          icon: Icon(
            Icons.arrow_downward_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 22,
          ),
          tooltip: 'Downvote',
        ),
      ),
    );
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
          if (post.imageUrl != null &&
              post.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: ApiHelper.image(
                  post.imageUrl!,
                  "api/posts/GetPostAttachment")
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      autherId: post.autherId,
                      autherUsername:
                          post.autherUsername,
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        post.autherUsername.isNotEmpty
                            ? post.autherUsername[0]
                                .toUpperCase()
                            : '?',
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
                          '@${post.autherUsername}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          post.createdIn ?? 'Unknown date',
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
                  post.title,
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
                    post.description,
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
                    _buildUpVote(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: post.numOfVotes > 0
                            ? colorScheme.primary.withOpacity(0.1)
                            : post.numOfVotes < 0
                                ? colorScheme.error.withOpacity(0.1)
                                : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: post.numOfVotes > 0
                              ? colorScheme.primary.withOpacity(0.5)
                              : post.numOfVotes < 0
                                  ? colorScheme.error.withOpacity(0.5)
                                  : colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
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
                    ),
                    _buildDownVote(),
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
          PostActionsMenu(
              autherId: post.autherId,
              itemId: post.postID,
              isPost: true)
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
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
                                    color: colorScheme.primaryContainer
                                        .withOpacity(0.2),
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
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
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
                                    side:
                                        BorderSide(color: colorScheme.primary),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
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
                            // Print all comments once for debugging
                            if (index == 0) {
                              print('All comments: $comments');
                              for (int i = 0; i < comments.length; i++) {
                                print(
                                    'Comment $i: username="${comments[i].username}"');
                              }
                            }

                            final comment = comments[index];
                            return CommentCard(
                              comment: comment,
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
                      enabled: post.allowComments,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: post.allowComments
                            ? 'Write a comment...'
                            : "Commenting is disabled",
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
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
                        onPressed: post.allowComments
                            ? addComment
                            : null,
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
