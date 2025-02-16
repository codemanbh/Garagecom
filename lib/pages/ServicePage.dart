import 'package:flutter/material.dart';
import 'package:garagecom/models/CarPart.dart';
import '../components/CustomNavBar.dart';
import '../models/ServiceParts.dart';
import 'package:image_picker/image_picker.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    ServiceParts serviceParts = ServiceParts();
    List<CarPart> carParts = serviceParts.parts;

    return Scaffold(
      appBar: AppBar(title: const Text('Service')),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: carParts.length,
                itemBuilder: (context, index) {
                  final part = carParts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                part.partName ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    part.imagePath = pickedFile.path;
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 150,
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Last Replaced (km)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    // Save the entered value to `lastReplaced`
                                    if (value.isNotEmpty) {
                                      part.lastReplaced = int.tryParse(value) ?? 0;
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Last Replaced (months)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    // Save the entered value to `lastReplacedTime`
                                    if (value.isNotEmpty) {
                                      part.lastReplacedTime = int.tryParse(value) ?? 0;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Save or submit the car parts replacement data
          serviceParts.savePartsList(); // Debug: Replace with saving logic
        },
        child: const Text('Save'),
      ),
      bottomNavigationBar: CustomNavBar(),
    );
  }
}
