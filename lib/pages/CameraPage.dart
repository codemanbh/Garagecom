import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../components/CustomNavBar.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  bool _isProcessing = false;
  String problems = '';

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _image = File(pickedFile.path);
          _isProcessing = false;
          problems = 'Engine Light, Low Tire Pressure';
        });
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing camera or gallery: $e')),
      );
    }
  }

  void _checkImage() {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image before submitting.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: const CustomNavBar(),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      _image != null ? _buildImagePreview(theme) : _buildImagePlaceholder(theme),
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
            _buildInstructionStep('Take a photo of your car dashboard', theme, Icons.camera_alt_outlined),
            _buildInstructionStep('Wait for AI to analyze the image', theme, Icons.autorenew),
            _buildInstructionStep('Review detected issues', theme, Icons.report_problem_outlined),
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
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
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
            Icon(Icons.camera_alt_outlined, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No image selected', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Take or upload a dashboard photo',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
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
        child: Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
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
            CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 3),
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
    final issuesList = problems.split(',');

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
            ...issuesList.map((issue) => _buildIssueItem(issue.trim(), theme)),
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
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
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

  Widget _buildIssueItem(String issue, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
        color: colorScheme.surface.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 20.0, color: colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              issue,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
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
                      side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
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
            onPressed: _checkImage,
            icon: const Icon(Icons.send_rounded),
            label: const Text(
              'Submit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            ),
          ),
        ],
      ),
    );
  }
}