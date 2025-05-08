import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImage extends StatefulWidget {
  final String? filename;
  ProfileImage({this.filename});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  File? _selectedImage;
  Uint8List? _currentImageBytes;
  bool _removeExistingImage = false;
  String? filename;
  @override
  void initState() {
    super.initState();
    filename = widget.filename;
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? imageFile = await _picker.pickImage(source: source);
    if (imageFile != null) {
      await ApiHelper.uploadImage(
          File(imageFile.path), 'api/Profile/SetAvatarAttachment');
      setState(() {
        _selectedImage = File(imageFile.path);
        _removeExistingImage = false;
        _currentImageBytes = null;
        filename = null;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          TextButton(
            child: const Text('Gallery'),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoPrompt(Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 40, color: color),
        const SizedBox(height: 8),
        Text('Add Photo',
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildImageDisplay() {
    if (_selectedImage != null) {
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    }
    if (_currentImageBytes != null && !_removeExistingImage) {
      return Image.memory(_currentImageBytes!, fit: BoxFit.cover);
    }
    if (filename != null && !_removeExistingImage) {
      return ApiHelper.image(
        filename ?? '',
        'api/Profile/GetAvatarAttachment',
      );
    }
    return _buildAddPhotoPrompt(Theme.of(context).colorScheme.primary);
  }

  void _deleteImage() {
    setState(() {
      _removeExistingImage = true;
      _selectedImage = null;
      _currentImageBytes = null;
      filename = null;
    });
  }

  Widget _buildDeleteButton() {
    if ((_currentImageBytes != null || filename != null) &&
        !_removeExistingImage) {
      return Positioned(
        bottom: 4,
        right: 4,
        child: CircleAvatar(
          backgroundColor: Colors.red,
          radius: 18,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.white, size: 18),
            onPressed: _deleteImage,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: CircleAvatar(
            radius: 80,
            backgroundColor: Colors.grey[300],
            child: ClipOval(
              child: SizedBox(
                height: 160,
                width: 160,
                child: _buildImageDisplay(),
              ),
            ),
          ),
        ),
        _buildDeleteButton(),
      ],
    );
  }
}
