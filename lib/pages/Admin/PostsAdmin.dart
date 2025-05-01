import 'package:flutter/material.dart';
import '../../components/PostCard.dart';
import '../../models/Post.dart';
import '../../managers/PostsManager.dart';

class PostsAdminTab extends StatefulWidget {
  const PostsAdminTab({super.key});

  @override
  PostsAdminTabState createState() => PostsAdminTabState();
}

class PostsAdminTabState extends State<PostsAdminTab> {
  late PostsManager _postsManager;
  late List<Post> posts;
  bool _isLoading = true;
  int _currentPostIndex = 0;
  
  // Static function to allow parent to trigger refresh
  static Function? refreshPosts;

  @override
  void initState() {
    super.initState();
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
      // This would ideally call a different API endpoint for pending/unapproved posts
      final success = await _postsManager.fetchPosts();

      if (success) {
        setState(() {
          posts = List.from(PostsManager.posts); // Create a copy
          _currentPostIndex = posts.isNotEmpty ? 0 : -1;
          _isLoading = false;
        });
      } else {
        setState(() {
          posts = [];
          _currentPostIndex = -1;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load pending posts'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
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

  void _nextPost() {
    if (posts.isNotEmpty && _currentPostIndex < posts.length - 1) {
      setState(() {
        _currentPostIndex++;
      });
    }
  }

  void _previousPost() {
    if (posts.isNotEmpty && _currentPostIndex > 0) {
      setState(() {
        _currentPostIndex--;
      });
    }
  }

  Future<void> _approvePost(Post post) async {
    try {
      // Call API or service to approve the post
      // await _postsManager.approvePost(post.id);
      
      // Remove the post from the pending list
      setState(() {
        posts.remove(post);
        if (posts.isEmpty) {
          _currentPostIndex = -1;
        } else if (_currentPostIndex >= posts.length) {
          _currentPostIndex = posts.length - 1;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
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
      // Call API or service to block the post
      // await _postsManager.blockPost(post.id);
      
      // Remove the post from the pending list
      setState(() {
        posts.remove(post);
        if (posts.isEmpty) {
          _currentPostIndex = -1;
        } else if (_currentPostIndex >= posts.length) {
          _currentPostIndex = posts.length - 1;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post blocked successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
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
                            Icons.task_alt,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Posts Pending Review',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All posts have been moderated',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadPendingPosts,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: _currentPostIndex > 0
                                    ? _previousPost
                                    : null,
                                icon: const Icon(Icons.arrow_back),
                                tooltip: 'Previous post',
                                color: _currentPostIndex > 0
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.3),
                              ),
                              IconButton(
                                onPressed: _currentPostIndex < posts.length - 1
                                    ? _nextPost
                                    : null,
                                icon: const Icon(Icons.arrow_forward),
                                tooltip: 'Next post',
                                color: _currentPostIndex < posts.length - 1
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        
                        // Current post card
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Card(
                                elevation: 4,
                                shadowColor: colorScheme.primary.withOpacity(0.3),
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
                                      post: posts[_currentPostIndex],
                                      isAdminView: true,
                                    ),
                                    
                                    // Admin action buttons
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                                              onPressed: () => _approvePost(posts[_currentPostIndex]),
                                              icon: const Icon(Icons.check_circle_outline),
                                              label: const Text('Approve'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(100),
                                                ),
                                                elevation: 3,
                                                shadowColor: Colors.green.withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _blockPost(posts[_currentPostIndex]),
                                              icon: const Icon(Icons.block),
                                              label: const Text('Block'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(100),
                                                ),
                                                elevation: 3,
                                                shadowColor: Colors.red.withOpacity(0.5),
                                              ),
                                            ),
                                          ),
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