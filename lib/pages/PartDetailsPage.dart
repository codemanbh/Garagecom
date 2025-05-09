import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/CarPart.dart';
import 'package:intl/intl.dart';
import '../helpers/ApiHelper.dart';

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

  Future<void> updateCarPart() async {
    // First check if the last replacement date is set when interval is changed
    if (part.lastReplacedDate == null || part.lastReplacedDate!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Last replacement date is required when updating the service interval.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saving changes...'),
            duration: Duration(seconds: 1),
          ),
        );

        // Extract numeric value from the replacement interval if possible
        String intervalStr = part.replacementInterval ?? '';
        int? lifeTimeInterval;

        // Extract numeric values using regex
        final RegExp regExp = RegExp(r'(\d+)');
        final match = regExp.firstMatch(intervalStr);
        if (match != null) {
          lifeTimeInterval = int.tryParse(match.group(1) ?? '');
        }

        // If no valid number found, default to 3 months
        lifeTimeInterval ??= 3;

        // Get the correct carPartID from the widget arguments or navigation params
        final int carPartId = widget.part.carPartId ?? 0;

        // Prepare the API request with the correct ID
        final response = await ApiHelper.post('api/Cars/UpdateCarPart', {
          'carPartId': carPartId, 
          'lifeTimeInterval': lifeTimeInterval,
          'notes': part.notes,
          'lastReplacementDate': part.lastReplacedDate != null ? 
              DateFormat('yyyy-MM-dd').format(_parseDate(part.lastReplacedDate) ?? DateTime.now()) : null,
        });

        if (response['succeeded'] == true) {
          setState(() {
            isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Changes saved successfully!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          // Handle error response
          String errorMessage = response['message'] ?? 'Failed to update part';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle exception
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateCarPart();
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

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Part'),
          content: Text('Are you sure you want to delete ${part.partName ?? 'this part'}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePart();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePart() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleting part...'),
          duration: Duration(seconds: 1),
        ),
      );

      final int carPartId = widget.part.carPartId ?? 0;
      
      // Call the delete endpoint
      final response = await ApiHelper.post('api/Cars/DeleteCarPart', {
        'carPartId': carPartId,
      });

      if (response['succeeded'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Part deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to the previous screen
        Navigator.of(context).pop(true); // Return true to indicate successful deletion
      } else {
        // Handle error response
        String errorMessage = response['message'] ?? 'Failed to delete part';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _extractNumericValue(String? text) {
    if (text == null || text.isEmpty) return null;
    final RegExp regExp = RegExp(r'(\d+)');
    final match = regExp.firstMatch(text);
    return match?.group(1);
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

                    // Service Interval - Simplified without unit selection
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
                                TextFormField(
                                  initialValue: _extractNumericValue(part.replacementInterval),
                                  decoration: InputDecoration(
                                    labelText: 'Interval in months',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    hintText: 'e.g., 6',
                                    helperText: 'Last replacement date is required when updating interval',
                                    helperStyle: TextStyle(
                                      color: colorScheme.error.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onSaved: (value) => part.replacementInterval = value,
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

                    // Notes - Always show the notes section regardless of edit mode
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
                          ? TextFormField(
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
                            )
                          : ListTile(
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
                                part.notes ?? 'No notes available',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                    ),

                    // Save button (only visible in edit mode)
                    if (isEditing)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _saveChanges,
                          icon: const Icon(Icons.save ,color: Colors.white,),
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
      floatingActionButton: !isEditing
          ? FloatingActionButton.extended(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Part'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}