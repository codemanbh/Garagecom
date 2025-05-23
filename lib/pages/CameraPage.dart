import 'package:flutter/material.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  bool _isProcessing = false;
  List<dynamic> problems = [];
  // Add a request cancellation token
  int _currentRequestId = 0;

  Future<XFile?> pickAndResizeImage(ImageSource source) async {
    const int maxShortSide = 768;
    const int maxLongSide = 2000;

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return null;

    final bytes = await pickedFile.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return null;

    int originalWidth = original.width;
    int originalHeight = original.height;

    int shortSide =
        originalWidth < originalHeight ? originalWidth : originalHeight;
    int longSide =
        originalWidth > originalHeight ? originalWidth : originalHeight;

    double shortScale = maxShortSide / shortSide;
    double longScale = maxLongSide / longSide;

    double scale = shortScale < longScale ? shortScale : longScale;

    if (scale >= 1.0) {
      // No resizing needed, return original as XFile
      return pickedFile;
    }

    int newWidth = (originalWidth * scale).round();
    int newHeight = (originalHeight * scale).round();

    final resized =
        img.copyResize(original, width: newWidth, height: newHeight);

    final resizedBytes = img.encodeJpg(resized, quality: 85);

    // Save to temp file
    final tempDir = Directory.systemTemp;
    final filePath = path.join(
        tempDir.path, 'resized_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final resizedFile = await File(filePath).writeAsBytes(resizedBytes);

    return XFile(resizedFile.path);
  }

  Future<void> _pickImage(ImageSource source) async {
    const int maxShortSide = 768;
    const int maxLongSide = 2000;
    final ImagePicker picker = ImagePicker();

    try {
      setState(() {
        _isProcessing = true;
        // Increment the request ID to invalidate any pending requests
        _currentRequestId++;
        // Clear any previous results when picking a new image
        problems = [];
      });

      // Use image_picker directly - it will handle permissions internally
      final XFile? pickedFile = await pickAndResizeImage(source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isProcessing = false;
        });
      } else {
        // User canceled the picker
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      // Handle specific permission denied error
      if (e.toString().contains('permission')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Camera permission is required. Please enable it in app settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      } else {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing camera or gallery: $e')),
        );
      }
    }
  }

  void _checkImage() {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select an image before submitting.')),
      );
      return;
    }

    // Set processing state to true before sending the request
    setState(() {
      _isProcessing = true;
    });

    // Create a local copy of the current request ID
    final int requestId = _currentRequestId;

    ApiHelper.uploadImage(_image!, '/api/Dashboard/GetDashboardSigns')
        .then((response) {
      // Check if this response is for the most recent request
      if (requestId != _currentRequestId) {
        // This response is for an old request, ignore it
        return;
      }

      if (response['succeeded'] == true) {
        setState(() {
          print(response);
          print(response["parameters"]['defects']);
          problems = List.from(response["parameters"]['defects']);
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image Processed successfully!')),
        );
      } else {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit image.')),
        );
      }
    }).catchError((error) {
      // Check if this error is for the most recent request
      if (requestId != _currentRequestId) {
        // This error is for an old request, ignore it
        return;
      }

      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting image: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analysis',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: Image.asset(
                'assets/images/dark_dashboard_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 8),
                      _buildHeaderBanner(theme),
                      const SizedBox(height: 16),
                      _buildInstructionsCard(theme),
                      const SizedBox(height: 16),
                      _image != null
                          ? _buildImagePreview(theme)
                          : _buildImagePlaceholder(theme),
                      const SizedBox(height: 16),
                      if (_isProcessing)
                        _buildProcessingIndicator(theme)
                      else if (problems.isNotEmpty && _image != null)
                        _buildResultsCard(theme),
                    ],
                  ),
                ),
                _buildBottomActionBar(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Snap your dashboard to detect car issues with AI',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shadowColor: colorScheme.primary.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How It Works',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInstructionStep('Take a photo of your car dashboard', theme,
                Icons.camera_alt_outlined),
            _buildInstructionStep(
                'Wait for AI to analyze the image', theme, Icons.autorenew),
            _buildInstructionStep(
                'Review detected issues', theme, Icons.report_problem_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String text, ThemeData theme, IconData icon) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.secondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurface),
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
      shadowColor: colorScheme.primary.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined,
                size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No image selected',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Take or upload a dashboard photo',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shadowColor: colorScheme.primary.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(_image!,
            height: 200, width: double.infinity, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildProcessingIndicator(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shadowColor: colorScheme.primary.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            CircularProgressIndicator(
                color: colorScheme.primary, strokeWidth: 3),
            const SizedBox(height: 20),
            Text(
              "Analyzing dashboard...",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shadowColor: colorScheme.primary.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detected Issues',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              height: 24,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            ...problems.map((issue) => _buildDetailedIssueItem(issue, theme)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'We recommend consulting a mechanic for these issues.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedIssueItem(dynamic issue, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final title = issue["title"]?.toString().trim() ?? "Unknown Issue";
    final description =
        issue["description"]?.toString().trim() ?? "No description available";
    final solution =
        issue["solution"]?.toString().trim() ?? "No solution provided";
        final logo = issue["logo"]?.toString().trim() ?? "No logo available";

    // Default icon mapping based on common dashboard warning lights
    IconData getIssueIcon(String issueTitle) {
      final lowerTitle = issueTitle.toLowerCase();
      if (lowerTitle.contains('battery')) return Icons.battery_alert;
      if (lowerTitle.contains('abs')) return Icons.report_problem;
      if (lowerTitle.contains('oil')) return Icons.oil_barrel;
      if (lowerTitle.contains('temp') || lowerTitle.contains('temperature'))
        return Icons.thermostat;
      if (lowerTitle.contains('tire') || lowerTitle.contains('pressure'))
        return Icons.tire_repair;
      if (lowerTitle.contains('engine')) return Icons.car_repair;
      if (lowerTitle.contains('belt')) return Icons.line_style;
      if (lowerTitle.contains('fuel')) return Icons.local_gas_station;
      if (lowerTitle.contains('light')) return Icons.lightbulb;
      return Icons.warning_amber_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: colorScheme.error.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
        color: colorScheme.errorContainer.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                // Icon(
                //   getIssueIcon(title),
                //   color: colorScheme.error,
                //   size: 24,
                // ),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: ApiHelper.image(logo, 'api/Dashboard/GetDashboardSignAttachment'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Solution section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.build_outlined,
                      color: colorScheme.primary.withOpacity(0.8),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Solution:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            solution,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
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
                  onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
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
            onPressed: _isProcessing ? null : _checkImage,
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
              _isProcessing ? 'Processing...' : 'Submit',
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
