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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(part.partName ?? 'Part Details'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: isEditing ? _saveChanges : _toggleEditMode,
          ),
        ],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
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
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.build_rounded,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  part.partName ?? 'Car Part',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Maintenance schedule and details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Part Information
                    Text(
                      'Part Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    isEditing
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                            child: TextFormField(
                              initialValue: part.partName,
                              decoration: InputDecoration(
                                labelText: 'Part Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.build, color: colorScheme.primary),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              onSaved: (value) => part.partName = value,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a part name';
                                }
                                return null;
                              },
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                            child: ListTile(
                              leading: Icon(
                                Icons.build,
                                color: colorScheme.primary,
                              ),
                              title: Text(
                                'Part Name',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              subtitle: Text(
                                part.partName ?? 'Not specified',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),

                    // Service History section
                    const SizedBox(height: 24),
                    Text(
                      'Service History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Last Replacement Date
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                      child: isEditing
                          ? ListTile(
                              title: Text(
                                'Last Replacement Date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                lastReplacedController.text.isNotEmpty
                                    ? lastReplacedController.text
                                    : 'Select Date',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              leading: Icon(
                                Icons.calendar_today,
                                color: colorScheme.primary,
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onTap: () => _selectDate(context, true),
                            )
                          : ListTile(
                              leading: Icon(
                                Icons.calendar_today,
                                color: colorScheme.primary,
                              ),
                              title: Text(
                                'Last Replacement Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              subtitle: Text(
                                part.lastReplacedDate ?? 'Not specified',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                    ),

                    // Service Schedule section
                    const SizedBox(height: 24),
                    Text(
                      'Service Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Next Service Date
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                      child: isEditing
                          ? ListTile(
                              title: Text(
                                'Next Service Date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                nextReplacedController.text.isNotEmpty
                                    ? nextReplacedController.text
                                    : 'Select Date',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              leading: Icon(
                                Icons.event,
                                color: colorScheme.primary,
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onTap: () => _selectDate(context, false),
                            )
                          : ListTile(
                              leading: Icon(
                                Icons.event,
                                color: colorScheme.primary,
                              ),
                              title: Text(
                                'Next Service Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              subtitle: Text(
                                part.nextReplacedDate ?? 'Not specified',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                    ),

                    // Service Interval
                    const SizedBox(height: 16),
                    Text(
                      'Service Interval',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      child: isEditing
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Service Interval',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedIntervalValue,
                                        decoration: InputDecoration(
                                          labelText: 'Value',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
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
                                            replacementIntervalController.text = newValue ?? '';
                                          });
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
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        items: intervalUnits.map((String unit) {
                                          return DropdownMenuItem<String>(
                                            value: unit,
                                            child: Text(unit),
                                          );
                                        }).toList(),
                                        onChanged: _handleIntervalUnitChange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : ListTile(
                              leading: Icon(
                                Icons.update,
                                color: colorScheme.primary,
                              ),
                              title: Text(
                                'Service Interval',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              subtitle: Text(
                                part.replacementInterval ?? 'Not specified',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                    ),

                    // Lifespan progress
                    const SizedBox(height: 16),
                    Text(
                      'Lifespan Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getProgressColor(part.lifespanProgress),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${((part.lifespanProgress ?? 0.0) * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: part.lifespanProgress ?? 0.0,
                              backgroundColor: Colors.grey[200],
                              color: _getProgressColor(part.lifespanProgress),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Additional Details
                    const SizedBox(height: 24),
                    Text(
                      'Additional Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Store Location
                    isEditing
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                            child: TextFormField(
                              initialValue: part.storeLocation,
                              decoration: InputDecoration(
                                labelText: 'Store Location',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.store, color: colorScheme.primary),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              onSaved: (value) => part.storeLocation = value,
                            ),
                          )
                        : part.storeLocation != null && part.storeLocation!.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.only(bottom: 16),
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
                                child: ListTile(
                                  leading: Icon(
                                    Icons.store,
                                    color: colorScheme.primary,
                                  ),
                                  title: Text(
                                    'Store Location',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  subtitle: Text(
                                    part.storeLocation ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),

                    // Notes
                    isEditing
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                            child: TextFormField(
                              initialValue: part.notes,
                              decoration: InputDecoration(
                                labelText: 'Notes',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.note, color: colorScheme.primary),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              maxLines: 3,
                              onSaved: (value) => part.notes = value,
                            ),
                          )
                        : part.notes != null && part.notes!.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.only(bottom: 16),
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
                                child: ListTile(
                                  leading: Icon(
                                    Icons.note,
                                    color: colorScheme.primary,
                                  ),
                                  title: Text(
                                    'Notes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  subtitle: Text(
                                    part.notes ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),

                    // Images section
                    const SizedBox(height: 24),
                    Text(
                      'Images',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Item Image
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(8),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                            child: Text(
                              'Item Image',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: isEditing ? () => _pickImage(false) : null,
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: part.itemImagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(part.itemImagePath!),
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
                                            color: isEditing
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            isEditing ? 'Tap to upload image' : 'No image available',
                                            style: TextStyle(
                                              color: isEditing
                                                  ? colorScheme.onSurfaceVariant
                                                  : colorScheme.onSurfaceVariant.withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Receipt Image
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(8),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                            child: Text(
                              'Receipt Image',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: isEditing ? () => _pickImage(true) : null,
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: part.receiptImagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(part.receiptImagePath!),
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
                                            color: isEditing
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            isEditing ? 'Tap to upload receipt' : 'No receipt available',
                                            style: TextStyle(
                                              color: isEditing
                                                  ? colorScheme.onSurfaceVariant
                                                  : colorScheme.onSurfaceVariant.withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Save button (only visible in edit mode)
                    if (isEditing)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _saveChanges,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            elevation: 4,
                            shadowColor: colorScheme.primary.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}