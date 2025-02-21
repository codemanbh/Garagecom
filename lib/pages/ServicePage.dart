import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/CustomNavBar.dart';
import '../models/CarPart.dart';
import '../models/ServiceParts.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ServiceParts serviceParts = ServiceParts();
    final List<CarPart> carParts = serviceParts.parts;

    void goToAddPartPage() {
      Navigator.of(context).pushNamed('/AddPartPage');
    }

    return Scaffold(
      // Use Material 3 if desired
      appBar: AppBar(
        title: const Text('Service'),
        // Round app bar
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(
        //     bottom: Radius.circular(30),
        //   ),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: goToAddPartPage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: carParts.length,
          itemBuilder: (context, index) {
            final part = carParts[index];
            return Card(
              // ElevatedCard is a Material 3 widget. If you’re not on Material 3,
              // you can use a normal Card with elevation & shape set.
              // style: CardTheme.of(context).style?.copyWith(
              //       shape: MaterialStateProperty.all(
              //         RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(16.0),
              //         ),
              //       ),
              //     ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Part name + camera icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          part.partName ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              part.imagePath = pickedFile.path;
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    // Middle row: Last replaced by km and months
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Last Replaced (km)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                part.lastReplaced = int.tryParse(value) ?? 0;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Last Replaced (months)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                part.lastReplacedTime =
                                    int.tryParse(value) ?? 0;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Save or submit the car parts replacement data
          serviceParts.savePartsList(); // Replace with your own saving logic
        },
        label: const Text('Save'),
        icon: const Icon(Icons.save),
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
