import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/CustomNavBar.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    print(
        "------------------------->" + (dotenv.env['ROBOFLOW_API_KEY'] ?? ''));
  }

  File? _image;
  bool _isProcessing = false;
  String problems = '';

  Future<Response> uploadImage(File imageFile, String apiKey) async {
    final String endpoint =
        'https://detect.roboflow.com/detect-car-signals-svgxz/1';

    // Read image bytes
    final bytes = await imageFile.readAsBytes();

    // Encode image to Base64
    final base64Image = base64Encode(bytes);

    // Initialize Dio
    final dio = Dio();

    try {
      // Send POST request with Base64-encoded image
      final response = await dio.post(
        '$endpoint?api_key=$apiKey',
        data: base64Image,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          },
        ),
      );

      // Check for successful response
      if (response.statusCode == 200) {
        print('Upload successful: ${response.data}');
        Map<String, dynamic> data = response.data;
        // Now you can access the data as a Map
        problems = '';
        data['predictions'].forEach((x) => problems += x['class'] + '\n');

        setState(() {});
        // data['predictions'].map((x) => problems += x['class'] + ' ');
        // print(data['key']);
        ;

        setState(() {});
      } else {
        print(
            'Upload failed: ${response.statusCode} - ${response.statusMessage}');
      }

      return response;
    } catch (e) {
      print('Exception occurred: $e');
      rethrow;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _isProcessing = true;
      });

      // await Future.delayed(Duration(seconds: 2)); // Simulating processing time

      _image = File(pickedFile.path);

      await uploadImage(_image!, dotenv.env['ROBOFLOW_API_KEY'] ?? '');

      _isProcessing = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Car Dashboard Analysis')),
      bottomNavigationBar: CustomNavBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Instructions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                  "1. Click 'Open Camera' or 'Choose from Gallery' to select an image."),
              Text("2. Capture or select a clear image of the car dashboard."),
              Text("3. Wait for processing."),
              Text("4. Review the processed image and problem signs meaning."),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    label: Text('Open Camera'),
                    iconAlignment: IconAlignment.end,
                    icon: Icon(Icons.camera_alt_outlined),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                      iconAlignment: IconAlignment.end,
                      onPressed: () => _pickImage(ImageSource.gallery),
                      label: Text('Choose from Gallery'),
                      icon: Icon(Icons.photo_library_outlined)),
                ],
              ),
              SizedBox(height: 20),
              if (_isProcessing) Center(child: CircularProgressIndicator()),
              if (_image != null && !_isProcessing) ...[
                Center(child: Image.file(_image!, height: 250)),
                SizedBox(height: 10),
                Text(problems,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
