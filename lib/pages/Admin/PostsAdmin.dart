import 'package:flutter/material.dart';
import '../../components/PostCard.dart';
import '../../models/Post.dart';
import '../../managers/PostsManager.dart';
import '../../helpers/apiHelper.dart';

class PostsAdminTab extends StatefulWidget {
  const PostsAdminTab({super.key});

  @override
  PostsAdminTabState createState() => PostsAdminTabState();
}

class PostsAdminTabState extends State<PostsAdminTab>
    with TickerProviderStateMixin {
  late PostsManager _postsManager;
  late TabController _tabController;
  // Initialize the posts list with an empty list instead of using late
  List<Post> posts = []; // Changed from 'late List<Post> posts'
  bool _isLoading = true;
  int _currentPostIndex = 0;

  // Static function to allow parent to trigger refresh
  static Function? refreshPosts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this); // CHANGE THIS VALUE to match your tabs
    _postsManager = PostsManager();
    _loadPendingPosts();

    // Set the refresh function
    refreshPosts = _loadPendingPosts;
  }

  @override
  void dispose() {
    // Clear the refresh function
    refreshPosts = null;
    super.dispose();
  }

  Future<void> _loadPendingPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the specific endpoint for getting new reports
      final response =
          await ApiHelper.get('api/Administrations/GetNewReport', {});
      print('Admin reports response: $response'); // Add logging to debug

      if (response['succeeded'] == true && response['parameters'] != null) {
        // The response format is different than expected
        // It contains a single Report object, not an array of reports
        final reportData = response['parameters']['Report'];
        print('Report data: $reportData'); // Debug info

        if (reportData != null) {
          // Get the specific post ID that was reported
          final int? postId = reportData['postID'];
          final int? commentId = reportData['commentID'];

          if (postId != null) {
            // If we have a postId, we need to fetch the post details
            final postResponse = await ApiHelper.get('api/Posts/GetPostByUserID', {'postId': postId});
            print('Post details response: $postResponse');

            if (postResponse['succeeded'] == true &&
                postResponse['parameters'] != null &&
                postResponse['parameters']['Post'] != null) {
              final postData = postResponse['parameters']['Post'];

              setState(() {
                // Clear existing posts
                PostsManager.posts =
                    []; // Update the static list in PostsManager
                posts = []; // Clear local list

                // Create a Post object from the post data
                Post post = Post(
                  postID: postData['postID'] ?? 0,
                  title: postData['title'] ?? 'No Title',
                  description: postData['description'] ?? 'No Content',
                  autherUsername: postData['userName'] ?? 'Unknown User',
                  imageUrl: postData['attachment'],
                  autherId: postData['userID'] ?? -1,
                  allowComments: postData['allowComments'] ?? true,
                  numOfVotes: postData['countVotes'] ?? 0,
                  voteValue: postData['voteValue'] ?? 0,
                  createdIn: postData['createdIn'] ?? '',
                  categoryName: postData['postCategory'] != null
                      ? postData['postCategory']['title']
                      : '',
                );

                posts.add(post);
                PostsManager.posts.add(post); // Add to the static list too

                _currentPostIndex = 0;
                _isLoading = false;
              });
            } else {
              // Couldn't fetch post details
              setState(() {
                posts = [];
                PostsManager.posts = [];
                _currentPostIndex = -1;
                _isLoading = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load post details'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          } else if (commentId != null) {
            // Handle comment reports here if needed
            // For now, just show a message that we have a comment report
            setState(() {
              posts = [];
              PostsManager.posts = [];
              _currentPostIndex = -1;
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Comment reports are not implemented yet'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else {
            // No post or comment ID in the report
            setState(() {
              posts = [];
              PostsManager.posts = [];
              _currentPostIndex = -1;
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid report data received'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        } else {
          // No reports found
          setState(() {
            posts = [];
            PostsManager.posts = [];
            _currentPostIndex = -1;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No pending reports found'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } else {
        setState(() {
          posts = [];
          PostsManager.posts = []; // Clear the static list too
          _currentPostIndex = -1;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['message'] ?? 'Failed to load pending reports'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      print('Error loading admin reports: $e'); // Add logging to debug
      setState(() {
        _isLoading = false;
        _currentPostIndex = -1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _approvePost(Post post) async {
    try {
      print('Approving post: ${post.postID}');
      // Call API to approve the post
      final response = await ApiHelper.post('api/Administrations/ProcessReport',
          {'postId': post.postID, 'commentId': null, 'action': 'allow'});

      print('Approve post response: $response'); // Add logging

      if (response['succeeded'] == true) {
        // Successfully processed the report
        setState(() {
          posts.clear();
          PostsManager.posts.clear();
          _currentPostIndex = -1;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post approved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Load the next report if available
        _loadPendingPosts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to approve post: ${response['message'] ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error approving post: $e'); // Add logging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve post: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _blockPost(Post post) async {
    try {
      print('Blocking post: ${post.postID}');
      // Call API to block the post
      final response = await ApiHelper.post('api/Administrations/ProcessReport',
          {'postId': post.postID, 'commentId': null, 'action': 'block'});

      print('Block post response: $response'); // Add logging

      if (response['succeeded'] == true) {
        // Successfully processed the report
        setState(() {
          posts.clear();
          PostsManager.posts.clear();
          _currentPostIndex = -1;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post blocked successfully'),
            backgroundColor: Colors.red,
          ),
        );

        // Load the next report if available
        _loadPendingPosts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to block post: ${response['message'] ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error blocking post: $e'); // Add logging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to block post: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Post Moderation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Review and moderate community posts',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (posts.isNotEmpty)
                Text(
                  'Post ${_currentPostIndex + 1} of ${posts.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                )
              : posts.isEmpty || _currentPostIndex < 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Reports Pending Review',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All reported content has been moderated',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadPendingPosts,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Check for Reports'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Navigation buttons

                        // Current post card
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Card(
                                elevation: 4,
                                shadowColor:
                                    colorScheme.primary.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: colorScheme.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Post content
                                    PostCard(
                                      postIndex: _currentPostIndex,
                                      isAdminView: true,
                                    ),

                                    // Admin action buttons
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 12.0),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerLow,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _blockPost(
                                                  posts[_currentPostIndex]),
                                              icon: const Icon(Icons.block),
                                              label: const Text('Block'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                elevation: 3,
                                                shadowColor:
                                                    Colors.red.withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _approvePost(
                                                  posts[_currentPostIndex]),
                                              icon: const Icon(
                                                  Icons.check_circle_outline),
                                              label: const Text('Approve'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                elevation: 3,
                                                shadowColor: Colors.green
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}
