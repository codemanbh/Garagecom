import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({super.key});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  File? _selectedImage;
  Uint8List? _currentImageBytes;
  bool _removeExistingImage = false;
  String? imageURL =
      "${ApiHelper.mainDomain}api/Profile/GetAvatarAttachment?filename=DashboardSign_7c20896e-8145-4550-b1c9-52101756c692"; // Example URL
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(imageURL);
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? imageFile = await _picker.pickImage(source: source);
    if (imageFile != null) {
      setState(() {
        _selectedImage = File(imageFile.path);
        _removeExistingImage = false;
        _currentImageBytes = null;
        imageURL = null; // remove remote URL if user picked a new one
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          actions: [
            TextButton(
              child: const Text('Camera'),
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            TextButton(
              child: const Text('Gallery'),
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : (_currentImageBytes != null && !_removeExistingImage)
                        ? Image.memory(_currentImageBytes!, fit: BoxFit.cover)
                        : (imageURL != null && !_removeExistingImage)
                            ? ApiHelper.image(
                                'DashboardSign_7c20896e-8145-4550-b1c9-52101756c692',
                                'api/Profile/GetAvatarAttachment')
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: scheme.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add Photo',
                                    style: TextStyle(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
              ),
            ),
          ),
        ),
        if ((_currentImageBytes != null || imageURL != null) &&
            !_removeExistingImage)
          Positioned(
            bottom: 4,
            right: 4,
            child: CircleAvatar(
              backgroundColor: Colors.red,
              radius: 18,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                onPressed: () {
                  setState(() {
                    _removeExistingImage = true;
                    _selectedImage = null;
                    _currentImageBytes = null;
                    imageURL = null;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}
