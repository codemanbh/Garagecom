import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../components/CategoriesDialog.dart';
import '../managers/CategoryManager.dart';
import '../helpers/apiHelper.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _selectedImage;
  bool _allowComments = true; // Comment toggle state
  bool _isLoading = false; // Loading state
    bool _isProcessing = false;


  @override
  void initState() {
    super.initState();
    // Pre-fetch categories when page loads
    CategoryManager.fetchCategories();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing camera or gallery: $e')),
      );
    }
  }

  void _submitPost() async {
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a title and description')),
      );
      return;
    }

    if (CategoryManager.selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category for your post')),
      );
      return;
    }

    // Show loading indicator
    setState(() {
      // _isLoading = true;
      _isProcessing = true;
    });

    try {
      // Debug log the input values
      print('Creating post with:');
      print('Title: $title');
      print('Description: $description');
      print('Allow Comments: $_allowComments');
      print('Category ID: ${CategoryManager.selectedCategoryId}');

      // Format the data as expected by your API, with the correct parameter name
      Map<String, dynamic> postData = {
        'title': title,
        'description': description,
        'allowComments': _allowComments,
        'postCategoryID': CategoryManager
            .selectedCategoryId, // Use 'postCategoryID' instead of 'categoryId'
      };

      print('Post data: $postData');

      // If there's an image, we need to handle that with a multipart request
      if (_selectedImage != null) {
        await _submitPostWithImage(title, description);
      } else {
        // Make regular API call for text-only post
        final response = await ApiHelper.post('api/Posts/Setpost', postData);

        print('API Response: $response');
        _handlePostResponse(response);
      }
    } catch (e) {
      print('Exception in _submitPost: $e');
      setState(() {
        _isLoading = false;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Helper method to handle multipart request with image
  Future<void> _submitPostWithImage(String title, String description) async {
    try {
      print('Creating post with image');

      // Create a FormData object with the correct field name for the category ID
      FormData formData = FormData.fromMap({
        'title': title,
        'description': description,
        'allowComments': _allowComments,
        'postCategoryID': CategoryManager
            .selectedCategoryId, // Use the correct field name here too
      });

      // Add the image file
      String fileName = _selectedImage!.path.split('/').last;
      print('Image file name: $fileName');

      formData.files.add(
        MapEntry(
          'attachment',
          await MultipartFile.fromFile(
            _selectedImage!.path,
            filename: fileName,
          ),
        ),
      );

      // Get the Dio client
      Dio client = await ApiHelper.Client();

      // Set content type for multipart request
      client.options.headers['Content-Type'] = 'multipart/form-data';

      print('Making API call to api/Posts/Setpost with image');

      // Make the API call using the same correct endpoint
      final response = await client.post(
        'api/Posts/Setpost',
        data: formData,
      );

      print('API Response status: ${response.statusCode}');
      print('API Response data: ${response.data}');

      // Handle the response
      _handlePostResponse(response.data);
    } catch (e) {
      print('Exception in _submitPostWithImage: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Helper method to handle the API response
  void _handlePostResponse(dynamic response) {
    setState(() {
      _isLoading = false;
    });

    if (response['succeeded'] == true) {
      // Reset form on success
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedImage = null;
        _allowComments = true;
        CategoryManager.selectedCategoryId = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Post created successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      // Navigate back to previous screen
      Navigator.of(context).pop();
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to create post: ${response['message'] ?? 'Unknown error'}'),
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
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.create_rounded, size: 24),
            SizedBox(width: 8),
            Text(
              'Create Post',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.background,
                  colorScheme.surface.withOpacity(0.6),
                ],
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
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
                                'Post Category',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                CategoryManager.getSelectedCategoryName() ??
                                    'Select a category for your post',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      CategoryManager.selectedCategoryId != null
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                  fontWeight:
                                      CategoryManager.selectedCategoryId != null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await showCategoriesDialog(context, 'create');
                            // Force refresh UI to show selected category
                            setState(() {});
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Title Input with icon
                          Card(
                            elevation: 4,
                            color: colorScheme.surface,
                            shadowColor: colorScheme.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  width: 1),
                            ),
                            child: ListTile(
                              leading:
                                  Icon(Icons.title, color: colorScheme.primary),
                              title: TextField(
                                controller: _titleController,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Post Title',
                                  hintStyle: TextStyle(
                                      color: colorScheme.onSurfaceVariant),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description Input with icon
                          Card(
                            elevation: 4,
                            color: colorScheme.surface,
                            shadowColor: colorScheme.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  width: 1),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.description,
                                      color: colorScheme.primary),
                                  title: Text(
                                    'Description',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: TextField(
                                    controller: _descriptionController,
                                    maxLines: 4,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Write details about your post...',
                                      hintStyle: TextStyle(
                                          color: colorScheme.onSurfaceVariant),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: colorScheme.primary
                                                .withOpacity(0.5)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: colorScheme.primary,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.all(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Image preview or placeholder
                          _selectedImage != null
                              ? _buildImagePreview(theme)
                              : _buildImagePlaceholder(theme),

                          const SizedBox(height: 16),

                          // Allow Comments Toggle
                          Card(
                            elevation: 4,
                            color: colorScheme.surface,
                            shadowColor: colorScheme.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  width: 1),
                            ),
                            child: SwitchListTile(
                              title: Text(
                                'Allow Comments',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                _allowComments
                                    ? 'Users can comment on this post'
                                    : 'Comments are disabled',
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant),
                              ),
                              secondary: Icon(
                                _allowComments
                                    ? Icons.chat_bubble_outline
                                    : Icons.block,
                                color: _allowComments
                                    ? colorScheme.primary
                                    : colorScheme.error,
                              ),
                              value: _allowComments,
                              activeColor: colorScheme.primary,
                              activeTrackColor:
                                  colorScheme.primary.withOpacity(0.3),
                              inactiveTrackColor:
                                  colorScheme.onSurfaceVariant.withOpacity(0.3),
                              inactiveThumbColor: colorScheme.onSurfaceVariant,
                              onChanged: (value) {
                                setState(() {
                                  _allowComments = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom action bar
                  _buildBottomActionBar(theme),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      color: colorScheme.surface,
      shadowColor: colorScheme.primary.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.3), width: 1),
      ),
    );
  }

  Widget _buildImagePreview(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      color: colorScheme.surface,
      shadowColor: colorScheme.primary.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.3), width: 1),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_selectedImage!.path),
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.7),
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 36, height: 36),
                icon: const Icon(Icons.close, size: 20),
                color: colorScheme.error,
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withOpacity(0.0),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: colorScheme.primary),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    tooltip: 'Change image',
                  ),
                  IconButton(
                    icon: Icon(Icons.crop, color: colorScheme.secondary),
                    onPressed: () {
                      // Future crop functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Crop feature coming soon!'),
                          backgroundColor: colorScheme.primaryContainer,
                        ),
                      );
                    },
                    tooltip: 'Crop image',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          top:
              BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                  ),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: BorderSide(
                          color: colorScheme.primary.withOpacity(0.5)),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
         ElevatedButton.icon(
            onPressed: _isProcessing ? null : _submitPost,
            icon: _isProcessing 
                ? SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  ) 
                : const Icon(Icons.send_rounded),
            label: Text(
              _isProcessing ? 'Processing...' : 'Post',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 4,
              shadowColor: colorScheme.primary.withOpacity(0.5),
              disabledBackgroundColor: colorScheme.primary.withOpacity(0.6),
              disabledForegroundColor: colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
