import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/CarPart.dart';

class PartDetailsPage extends StatefulWidget {
  final CarPart part;

  const PartDetailsPage({super.key, required this.part});

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
          content: const Text('Changes saved successfully!'),
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

  Widget _buildEditableField({
    required String label,
    required String? value,
    required Function(String?) onSaved,
    required bool isEditing,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  labelText: label,
                  prefixIcon: _getIconForField(label, colorScheme),
                  hintText: 'Enter $label',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.onSurfaceVariant.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
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
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.onSurfaceVariant.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    _getIconForField(label, colorScheme),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        value ?? 'Not provided',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _getIconForField(String label, ColorScheme colorScheme) {
    IconData iconData;
    switch (label) {
      case 'Part Name':
        iconData = Icons.build;
        break;
      case 'Last Replaced Date':
        iconData = Icons.calendar_today;
        break;
      case 'Next Replaced Date':
        iconData = Icons.event_available;
        break;
      case 'Replacement Interval':
        iconData = Icons.update;
        break;
      case 'Store Location':
        iconData = Icons.store;
        break;
      case 'Notes':
        iconData = Icons.note;
        break;
      default:
        iconData = Icons.info;
    }
    return Icon(iconData, color: colorScheme.primary);
  }

  Widget _buildImageSection({
    required String label,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

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
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.onSurfaceVariant.withOpacity(0.2)),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Tap to upload $label',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
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