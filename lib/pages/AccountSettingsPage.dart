import 'package:flutter/material.dart';
import '../managers/UserService.dart';
import '../helpers/apiHelper.dart';
import '../components/ProfileImage.dart';
import '../components/PostCard.dart';
import '../managers/PostsManager.dart';
import '../models/Post.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  // API data
  Map<String, dynamic>? userData;
  List<Post> userPosts = [];
  bool isLoadingPosts = false;
  bool postsError = false;
  String postsErrorMessage = '';

  bool isEditMode = false;
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';

  // Controllers for editing text fields
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();

    // Load user data
    loadUserData();
  }

  @override
  void dispose() {
    // Clean up controllers
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      // Fetch user profile
      final profileResponse = await UserService.getUserProfile();

      setState(() {
        userData = profileResponse['parameters']['User'];

        // Update controllers with user data
        if (userData != null) {
          firstNameController.text = userData!['firstName'] ?? '';
          lastNameController.text = userData!['lastName'] ?? '';
          usernameController.text = userData!['userName'] ?? '';
          emailController.text = userData!['email'] ?? '';
          phoneController.text = userData!['phoneNumber'] ?? '';

          // Load user posts after profile is loaded
          if (userData!['userID'] != null) {
            loadUserPosts(userData!['userID']);
          }
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> loadUserPosts(int userId) async {
    setState(() {
      isLoadingPosts = true;
      postsError = false;
    });

    try {
      final response = await UserService.getUserPosts(userId);

      if (response['succeeded'] &&
          response['parameters'] != null &&
          response['parameters']['Posts'] != null) {
        List<dynamic> postsData = response['parameters']['Posts'];
        List<Post> loadedPosts = [];

        for (var postData in postsData) {
          Post post = Post(
            postID: postData['postID'] ?? 0,
            title: postData['title'] ?? 'No Title',
            description: postData['description'] ?? 'No Content',
            autherUsername: postData['userName'] ?? 'Unknown',
            imageUrl: postData['attachment'] != null &&
                    postData['attachment'].isNotEmpty
                ? postData['attachment']
                : null,
            autherId: postData['userID'] ?? -1,
            allowComments: postData['allowComments'] ?? true,
            numOfVotes: postData['countVotes'] ?? 0,
            voteValue: postData['voteValue'] ?? 0,
            createdIn: postData['createdIn'] ?? '',
            categoryName: postData['postCategory'] != null
                ? postData['postCategory']['title']
                : '',
          );

          loadedPosts.add(post);
        }

        setState(() {
          userPosts = loadedPosts;
          isLoadingPosts = false;
        });
      } else {
        setState(() {
          postsError = true;
          postsErrorMessage = response['message'] ?? 'Failed to load posts';
          isLoadingPosts = false;
        });
      }
    } catch (e) {
      setState(() {
        postsError = true;
        postsErrorMessage = e.toString();
        isLoadingPosts = false;
      });
    }
  }

  void _handleLogout() {
    ApiHelper.post('/api/Profile/Logout', {});
    ApiHelper.handleAnAuthorized();
  }

  Future<void> updateProfile() async {
    if (userData == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Update user data with edited values
      // Note: Not including username or email as they're not editable
      final updatedUserData = {
        'userID': userData!['userID'],
        'userName': userData!['userName'], // Use existing username
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': userData!['email'], // Use existing email
        'phoneNumber': phoneController.text,
      };

      // Call API to update profile
      final response = await UserService.updateUserProfile(updatedUserData);

      setState(() {
        isLoading = false;
        isEditMode = false;
        userData = response['parameters']['User'] ?? userData;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
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
        title: const Text('Profile'),
        actions: [
          if (!isLoading && !isError)
            IconButton(
              icon: Icon(isEditMode ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  isEditMode = !isEditMode;
                  if (!isEditMode) {
                    // Reset fields to current values
                    if (userData != null) {
                      firstNameController.text = userData!['firstName'] ?? '';
                      lastNameController.text = userData!['lastName'] ?? '';
                      usernameController.text = userData!['userName'] ?? '';
                      emailController.text = userData!['email'] ?? '';
                      phoneController.text = userData!['phoneNumber'] ?? '';
                    }
                  }
                });
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadUserData,
        color: colorScheme.primary,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : isError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: loadUserData,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        ProfileImage(
                          filename: userData!['attachmentName'],
                          username: 'asd',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData != null
                              ? '${userData!['firstName'] ?? ''} ${userData!['lastName'] ?? ''}'
                              : 'User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          userData != null
                              ? userData!['email'] ?? 'Email'
                              : 'Email',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (!isEditMode) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow
                                  .withOpacity(0.5),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to the admin page
                                    Navigator.of(context)
                                        .pushNamed('/adminPage');
                                  },
                                  child: Text(
                                    'Admin Page',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                buildInfoItem(
                                    'Username',
                                    userData != null
                                        ? userData!['userName'] ?? ''
                                        : '',
                                    Icons.account_circle),
                                buildInfoItem(
                                    'Full Name',
                                    userData != null
                                        ? '${userData!['firstName'] ?? ''} ${userData!['lastName'] ?? ''}'
                                        : '',
                                    Icons.person),
                                buildInfoItem(
                                    'Email',
                                    userData != null
                                        ? userData!['email'] ?? ''
                                        : '',
                                    Icons.email),
                                buildInfoItem(
                                    'Phone',
                                    userData != null
                                        ? userData!['phoneNumber'] ?? ''
                                        : '',
                                    Icons.phone),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
 ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                isEditMode = true;
                              });
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 4,
                              shadowColor: colorScheme.primary.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          // My Posts Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow
                                  .withOpacity(0.5),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'My Posts',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      if (isLoadingPosts)
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                if (isLoadingPosts)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Loading your posts...',
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  )
                                else if (postsError)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: colorScheme.error,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Error loading posts',
                                            style: TextStyle(
                                              color: colorScheme.error,
                                            ),
                                          ),
                                          Text(
                                            postsErrorMessage,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: () {
                                              if (userData != null && userData!['userID'] != null) {
                                                loadUserPosts(userData!['userID']);
                                              }
                                            },
                                            child: Text('Try Again'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else if (userPosts.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.article_outlined,
                                            color: colorScheme.onSurfaceVariant,
                                            size: 48,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'You haven\'t created any posts yet',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              // Navigate to create post page
                                              Navigator.of(context).pushNamed('/createPost');
                                            },
                                            icon: Icon(Icons.add),
                                            label: Text('Create Post'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: colorScheme.primary,
                                              foregroundColor: colorScheme.onPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  // Display user posts using a custom list of PostCards
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: userPosts.length,
                                    itemBuilder: (context, index) {
                                      // Add posts to PostsManager to be used by PostCard
                                      if (!PostsManager.posts.contains(userPosts[index])) {
                                        PostsManager.posts.add(userPosts[index]);
                                      }
                                      // Find the index of the post in the PostsManager.posts list
                                      int postIndex = PostsManager.posts.indexOf(userPosts[index]);
                                      return PostCard(
                                        postIndex: postIndex,
                                        isAdminView: false,
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                         
                          ElevatedButton.icon(
                            icon: Icon(Icons.logout),
                            onPressed: _handleLogout,
                            label: Text('Logout'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 4,
                              shadowColor: colorScheme.primary.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Edit mode UI
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                buildEditableField(
                                  label: 'Username',
                                  icon: Icons.account_circle,
                                  controller: usernameController,
                                  enabled: false,
                                ),
                                buildEditableField(
                                  label: 'First Name',
                                  icon: Icons.person_outline,
                                  controller: firstNameController,
                                ),
                                buildEditableField(
                                  label: 'Last Name',
                                  icon: Icons.person,
                                  controller: lastNameController,
                                ),
                                buildEditableField(
                                  label: 'Email',
                                  icon: Icons.email,
                                  controller: emailController,
                                  enabled: false,
                                ),
                                buildEditableField(
                                  label: 'Phone Number',
                                  icon: Icons.phone,
                                  controller: phoneController,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: updateProfile,
                                  child: const Text('Save Profile'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
      ),
    );
  }

  // Helper methods for UI components
  Widget buildInfoItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditableField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: enabled 
              ? theme.colorScheme.surface
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // Add a hint to indicate the field is not editable
          hintText: !enabled ? 'Not editable' : null,
          hintStyle: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
