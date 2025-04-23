import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/CarPart.dart';
import 'package:intl/intl.dart';

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

  // Controllers
  late TextEditingController lastReplacedController;
  late TextEditingController nextReplacedController;
  late TextEditingController replacementIntervalController;

  // For replacement interval menu
  String? selectedIntervalUnit = 'Months';
  final List<String> intervalUnits = ['Days', 'Weeks', 'Months', 'Years', 'Kilometers'];

  // Preset values for different interval units
  final Map<String, List<String>> presetIntervalValues = {
    'Days': ['7', '14', '30', '60', '90'],
    'Weeks': ['1', '2', '4', '6', '8', '12'],
    'Months': ['1', '3', '6', '9', '12', '18', '24'],
    'Years': ['1', '2', '3', '4', '5'],
    'Kilometers': ['1000', '5000', '10000', '15000', '20000', '30000', '50000'],
  };

  // Currently selected preset value
  String? selectedIntervalValue;

  @override
  void initState() {
    super.initState();
    part = widget.part;

    // Initialize controllers
    lastReplacedController = TextEditingController(text: part.lastReplacedDate);
    nextReplacedController = TextEditingController(text: part.nextReplacedDate);
    replacementIntervalController = TextEditingController();

    // Try to parse the interval to determine the unit and value
    _parseIntervalFromText();
  }

  @override
  void dispose() {
    lastReplacedController.dispose();
    nextReplacedController.dispose();
    replacementIntervalController.dispose();
    super.dispose();
  }

  void _parseIntervalFromText() {
    if (part.replacementInterval == null) return;

    final interval = part.replacementInterval!.toLowerCase();

    // Try to extract the numeric part from the interval
    final RegExp regExp = RegExp(r'(\d+)');
    final match = regExp.firstMatch(interval);

    if (match != null) {
      selectedIntervalValue = match.group(1);
      replacementIntervalController.text = selectedIntervalValue ?? '';
    }

    if (interval.contains('month') || interval.contains('months')) {
      selectedIntervalUnit = 'Months';
    } else if (interval.contains('year') || interval.contains('years')) {
      selectedIntervalUnit = 'Years';
    } else if (interval.contains('day') || interval.contains('days')) {
      selectedIntervalUnit = 'Days';
    } else if (interval.contains('week') || interval.contains('weeks')) {
      selectedIntervalUnit = 'Weeks';
    } else if (interval.contains('km') || interval.contains('kilometer')) {
      selectedIntervalUnit = 'Kilometers';
    }

    // If the value isn't in the preset list, just use the first value
    if (selectedIntervalValue == null ||
        !presetIntervalValues[selectedIntervalUnit]!.contains(selectedIntervalValue)) {
      selectedIntervalValue = presetIntervalValues[selectedIntervalUnit]?[0];
    }
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

      // Format the replacement interval with the selected value and unit
      if (selectedIntervalValue != null && selectedIntervalUnit != null) {
        part.replacementInterval = '$selectedIntervalValue $selectedIntervalUnit';
      }

      setState(() {
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Changes saved successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isLastReplaced) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = isLastReplaced
        ? _parseDate(part.lastReplacedDate) ?? now
        : _parseDate(part.nextReplacedDate) ?? now.add(const Duration(days: 180));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isLastReplaced ? DateTime(2000) : now,
      lastDate: isLastReplaced ? now : DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('MMM dd, yyyy').format(picked);
        if (isLastReplaced) {
          part.lastReplacedDate = formattedDate;
          lastReplacedController.text = formattedDate;
        } else {
          part.nextReplacedDate = formattedDate;
          nextReplacedController.text = formattedDate;
        }
      });
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateFormat('MMM dd, yyyy').parse(dateStr);
    } catch (e) {
      try {
        return DateFormat.yMMMd().parse(dateStr);
      } catch (e) {
        return null;
      }
    }
  }

  void _handleIntervalUnitChange(String? newUnit) {
    if (newUnit == null) return;

    setState(() {
      selectedIntervalUnit = newUnit;
      // Reset the selected value when changing units
      selectedIntervalValue = presetIntervalValues[newUnit]?[0];
      replacementIntervalController.text = selectedIntervalValue ?? '';
    });
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
              _buildDateField(
                label: 'Last Replaced Date',
                controller: lastReplacedController,
                onSaved: (value) => part.lastReplacedDate = value,
                isEditing: isEditing,
                isLastReplaced: true,
              ),
              const SizedBox(height: 16.0),
              // Next Replaced Date
              _buildDateField(
                label: 'Next Replaced Date',
                controller: nextReplacedController,
                onSaved: (value) => part.nextReplacedDate = value,
                isEditing: isEditing,
                isLastReplaced: false,
              ),
              const SizedBox(height: 16.0),
              // Replacement Interval
              _buildIntervalField(
                label: 'Replacement Interval',
                controller: replacementIntervalController,
                onSaved: (value) => replacementIntervalController.text = value ?? '',
                isEditing: isEditing,
              ),
              const SizedBox(height: 8.0),
              // Progress Indicator
              LinearProgressIndicator(
                value: part.lifespanProgress ?? 0.0,
                backgroundColor: Colors.grey[300],
                color: _getProgressColor(part.lifespanProgress),
                minHeight: 8.0,
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

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required Function(String?) onSaved,
    required bool isEditing,
    required bool isLastReplaced,
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
                controller: controller,
                readOnly: true,
                onTap: () => _selectDate(context, isLastReplaced),
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: _getIconForField(label, colorScheme),
                  suffixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
                  hintText: 'Select $label',
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
                onSaved: onSaved,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select $label';
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
                        controller.text.isNotEmpty ? controller.text : 'Not provided',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildIntervalField({
    required String label,
    required TextEditingController controller,
    required Function(String?) onSaved,
    required bool isEditing,
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
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: selectedIntervalValue,
                      decoration: InputDecoration(
                        labelText: 'Value',
                        prefixIcon: _getIconForField(label, colorScheme),
                        hintText: 'Select value',
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
                      items: presetIntervalValues[selectedIntervalUnit]?.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList() ?? [],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedIntervalValue = newValue;
                          controller.text = newValue ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a value';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: selectedIntervalUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
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
                      items: intervalUnits.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: _handleIntervalUnitChange,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a unit';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
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
                        part.replacementInterval ?? 'Not provided',
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
          onTap: isEditing ? onTap : null,
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
                          color: isEditing ? colorScheme.primary : colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          isEditing ? 'Tap to upload $label' : 'No $label available',
                          style: TextStyle(
                            color: isEditing ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withOpacity(0.5),
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