import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/CarPart.dart';

class PartDetailsPage extends StatefulWidget {
  final CarPart part;

  const PartDetailsPage({Key? key, required this.part}) : super(key: key);

  @override
  _PartDetailsPageState createState() => _PartDetailsPageState();
}

class _PartDetailsPageState extends State<PartDetailsPage> {
  final ImagePicker _picker = ImagePicker();
  late CarPart part;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    part = widget.part;
  }

  Future<void> _pickImage(bool isReceipt) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isReceipt) {
          part.receiptImagePath = pickedFile.path;
        } else {
          part.itemImagePath = pickedFile.path;
        }
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Changes saved successfully!'),
          backgroundColor: Theme.of(context).primaryColor, // Use theme color
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(part.partName ?? 'Part Details'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: isEditing ? _saveChanges : _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            
              const SizedBox(height: 16.0),
              // Part Name
              _buildEditableField(
                label: 'Part Name',
                value: part.partName,
                onSaved: (value) => part.partName = value,
                isEditing: isEditing,
              ),
              const SizedBox(height: 16.0),
              // Last Replaced Date
              _buildEditableField(
                label: 'Last Replaced Date',
                value: part.lastReplacedDate,
                onSaved: (value) => part.lastReplacedDate = value,
                isEditing: isEditing,
              ),
              const SizedBox(height: 16.0),
              // Next Replaced Date
              _buildEditableField(
                label: 'Next Replaced Date',
                value: part.nextReplacedDate,
                onSaved: (value) => part.nextReplacedDate = value,
                isEditing: isEditing,
              ),
              const SizedBox(height: 16.0),
              // Replacement Interval
              _buildEditableField(
                label: 'Replacement Interval',
                value: part.replacementInterval,
                onSaved: (value) => part.replacementInterval = value,
                isEditing: isEditing,
              ),
               const SizedBox(height: 8.0),
                      // Progress Indicator
                        LinearProgressIndicator(
                        value: part.lifespanProgress ?? 0.0, // A value between 0.0 and 1.0
                        backgroundColor: Colors.grey[300],
                        color: _getProgressColor(part.lifespanProgress),
                        minHeight: 8.0, // Increase the height of the progress bar
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                          'Lifespan Progress',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                          '${((part.lifespanProgress ?? 0.0) * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        ),
              const SizedBox(height: 16.0),
              // Store Location
              _buildEditableField(
                label: 'Store Location',
                value: part.storeLocation,
                onSaved: (value) => part.storeLocation = value,
                isEditing: isEditing,
              ),
              const SizedBox(height: 16.0),
              // Notes
              _buildEditableField(
                label: 'Notes',
                value: part.notes,
                onSaved: (value) => part.notes = value,
                isEditing: isEditing,
                maxLines: 3,
              ),
                // Item Image
              _buildImageSection(
                label: 'Item Image',
                imagePath: part.itemImagePath,
                onTap: () => _pickImage(false),
              ),
              const SizedBox(height: 16.0),
              // Receipt Image
              _buildImageSection(
                label: 'Receipt Image',
                imagePath: part.receiptImagePath,
                onTap: () => _pickImage(true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection({
    required String label,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Use card color
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.file(
                      File(imagePath),
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Theme.of(context).hintColor, // Use hint color
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Tap to upload $label',
                          style: TextStyle(
                            color: Theme.of(context).hintColor, // Use hint color
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required String? value,
    required Function(String?) onSaved,
    required bool isEditing,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8.0),
        isEditing
            ? TextFormField(
                initialValue: value,
                decoration: InputDecoration(
                  hintText: 'Enter $label',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, // Use primary color
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, // Use primary color
                    ),
                  ),
                ),
                maxLines: maxLines,
                onSaved: onSaved,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter $label';
                  }
                  return null;
                },
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, // Use card color
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  value ?? 'Not provided',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
      ],
    );
  }
  Color _getProgressColor(double? progress) {
    if (progress == null) return Colors.grey;
    if (progress > 0.75) {
      return Colors.green;
    } else if (progress > 0.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}