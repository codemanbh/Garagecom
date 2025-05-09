import 'package:flutter/material.dart';
import '../components/PostCard.dart';
import '../managers/PostsManager.dart';
import '../searchDelegates/PostSearchDelegate.dart';
import '../components/CategoriesDialog.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late PostsManager _postsManager;
  // late List<Post> posts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // _postsManager = PostsManager();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      PostsManager.posts.clear();
      PostsManager.postsPage = 0;
      final success = await PostsManager.fetchPosts();

      if (success) {
        setState(() {
          // posts = List.from(PostsManager.posts); // Create a copy
          _isLoading = false;
        });

        print(
            'HomePage loaded ${PostsManager.posts.length} posts successfully');
      } else {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load posts'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      print('Error in _loadPosts: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Cars Community'),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: PostSearchDelegate(),
                );
              },
              icon: const Icon(Icons.search))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createPostPage');
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add),
      ),
      body: LazyLoadScrollView(
        onEndOfPage: () {
          setState(() {
            if (PostsManager.hasMore && !PostsManager.isLoudingMore) {
              PostsManager.isLoudingMore = true;
              setState(() {
                print('more are fitched');
                PostsManager.fetchPosts();
              });

              // Future.delayed(Duration(milliseconds: 50), () {
              // Your action here
              PostsManager.isLoudingMore = false;
              // });
            }
          });
        },
        child: Column(
          children: [
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
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
                    Icons.category_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Post Categories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Filter posts by category',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await showCategoriesDialog(context, 'filter');
                      await _loadPosts();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: colorScheme.primary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      'Select',
                      style: TextStyle(fontSize: 14),
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
                  : PostsManager.posts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.post_add,
                                size: 64,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Posts Available',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select categories or check back later',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadPosts,
                          color: colorScheme.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            itemCount: PostsManager.posts.length +
                                (PostsManager.isLoudingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == PostsManager.posts.length) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              return PostCard(
                                postIndex: index,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
