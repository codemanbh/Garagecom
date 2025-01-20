import 'package:flutter/material.dart';
import '../components/CustomNavBar.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> carParts = [
      {'name': 'Oil Filter', 'lastReplaced': ''},
      {'name': 'Air Filter', 'lastReplaced': ''},
      {'name': 'Brake Pads', 'lastReplaced': ''},
      {'name': 'Tires', 'lastReplaced': ''},
      {'name': 'Battery', 'lastReplaced': ''},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'Popular Car Parts',
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            part['name'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 150,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Last Replaced (km)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                // Save the entered value to `lastReplaced`
                                part['lastReplaced'] = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Save or submit the car parts replacement data
                print(carParts); // Debug: Replace with saving logic
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(),
    );
  }
}
