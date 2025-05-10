import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'package:garagecom/utils/Validators.dart';
import 'package:intl/intl.dart';

class AddPartPage extends StatefulWidget {
  const AddPartPage({super.key});

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController partIdController = TextEditingController();
  TextEditingController partReplacedDistanceController =
      TextEditingController();
  TextEditingController partLifetimeDistanceController =
      TextEditingController();
  TextEditingController partLifetimeTimeController = TextEditingController();
  TextEditingController intervalValueController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  // Date controllers
  DateTime? replacementDate;
  DateTime? nextServiceDate;

  // Dropdown selection
  String? selectedPartType;
  String selectedIntervalUnit = 'Months';

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

  // List of common car parts for dropdown
  List<Map<String, dynamic>> partTypes = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    replacementDate = DateTime.now(); // Default to today
    nextServiceDate = DateTime.now()
        .add(const Duration(days: 180)); // Default to 6 months from now
    ;
    selectedIntervalValue = '3'; // Default to 3 months
    intervalValueController.text = selectedIntervalValue!;
    getPartTypes();
  }

  void getPartTypes() async {
    Map<String, dynamic> response =
        await ApiHelper.get('/api/Cars/GetParts', {});
    print('parts--------------------------------------');
    print(response['parameters']['Parts']);

    partTypes = List.from(response['parameters']['Parts']);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectReplacementDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: replacementDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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

    if (picked != null && picked != replacementDate) {
      setState(() {
        replacementDate = picked;
      });
    }
  }

  Future<void> _selectNextServiceDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          nextServiceDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
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

    if (picked != null && picked != nextServiceDate) {
      setState(() {
        nextServiceDate = picked;
      });
    }
  }

  // Get the icon for the selected part
  IconData _getPartIcon(int partID) {
    return Icons.car_crash;
  }

  void _handleIntervalUnitChange(String? newUnit) {
    if (newUnit == null) return;

    setState(() {
      selectedIntervalUnit = newUnit;
      // Reset the selected value when changing units
      selectedIntervalValue = presetIntervalValues[newUnit]?[0];
      intervalValueController.text = selectedIntervalValue ?? '';
    });
  }

  void handleSave() async {
    if (_formKey.currentState!.validate()) {
      // Format the interval with the selected value and unit
      final String formattedInterval =
          selectedIntervalValue != null && selectedIntervalUnit != null
              ? '$selectedIntervalValue $selectedIntervalUnit'
              : '';

      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final carId = args['carId'];

      Map<String, dynamic> data = {
        "carId": carId,
        "partId": partIdController.text,
        "lastReplacementDate": replacementDate != null
            ? DateFormat('yyyy-MM-dd').format(replacementDate!)
            : null,
        "lifeTimeInterval": intervalValueController.text,
        "notes": notesController.text
      };

      print(data);

      setState(() {
        _isProcessing = true;
      });

      Map<String, dynamic> response =
          await ApiHelper.post('/api/Cars/SetCarPart', data);

      setState(() {
        _isProcessing = false;
      });

      print(response);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Part'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
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
                              color:
                                  colorScheme.primaryContainer.withOpacity(0.3),
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
                                    Icons.handyman_rounded,
                                    color: colorScheme.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add Car Part',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Track maintenance for your vehicle components',
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

                          // Part selection dropdown
                          Text(
                            'Part Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
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
                            child: DropdownButtonFormField<String>(
                              value: selectedPartType,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedPartType = newValue;
                                  partIdController.text = newValue ?? '';
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Select Part Type',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              icon: Icon(Icons.arrow_drop_down,
                                  color: colorScheme.primary),
                              items: partTypes.map((Map<String, dynamic> part) {
                                return DropdownMenuItem<String>(
                                  value: part['partID'].toString(),
                                  child: Row(
                                    children: [
                                      Icon(_getPartIcon(part['partID']),
                                          size: 20, color: colorScheme.primary),
                                      const SizedBox(width: 12),
                                      Text(part['partName']),
                                    ],
                                  ),
                                );
                              }).toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a part type';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Custom part name field (visible if "Other" is selected)
                          if (selectedPartType == 'Other (Custom)')
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
                              child: TextFormField(
                                controller: partIdController,
                                decoration: InputDecoration(
                                  labelText: 'Custom Part Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(Icons.build,
                                      color: colorScheme.primary),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a part name';
                                  }
                                  return null;
                                },
                              ),
                            ),

                          // Replacement date picker
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
                            child: ListTile(
                              title: Text(
                                'Last Replacement Date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                replacementDate != null
                                    ? DateFormat('MMM dd, yyyy')
                                        .format(replacementDate!)
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
                              onTap: () => _selectReplacementDate(context),
                            ),
                          ),

                          const SizedBox(height: 24),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
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
                                Text(
                                  'Service Interval (Months)',
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
                                        child: TextFormField(
                                          validator: Validators.interval,
                                          controller: intervalValueController,
                                          keyboardType: TextInputType.number,
                                        )),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ],
                            ),
                          ),

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
                            child: TextFormField(
                              controller: notesController,
                              decoration: InputDecoration(
                                labelText: 'Notes',
                                hintText:
                                    'Add any additional notes about this part',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.note,
                                    color: colorScheme.primary),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              maxLines: 3,
                            ),
                          ),

                          // Save button
                          Center(
                            child: _isProcessing
                                ? CircularProgressIndicator()
                                : ElevatedButton.icon(
                                    onPressed: handleSave,
                                    icon: Icon(Icons.add,
                                        color: colorScheme.onPrimary),
                                    label: const Text('Add Part'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 16),
                                      elevation: 4,
                                      shadowColor:
                                          colorScheme.primary.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
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
