import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/CustomNavBar.dart';
import '../models/CarPart.dart';
import '../models/ServiceParts.dart';
import 'PartDetailsPage.dart'; // Import the new details page

class ServicePage extends StatelessWidget {
  const ServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ServiceParts serviceParts = ServiceParts();
    final List<CarPart> carParts = serviceParts.parts;

    void goToAddPartPage() {
      Navigator.of(context).pushNamed('/AddPartPage');
    }

    void goToPartDetailsPage(CarPart part) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PartDetailsPage(part: part),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service'),
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
            return GestureDetector(
              onTap: () => goToPartDetailsPage(part),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Part Name
                      Text(
                        part.partName ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12.0),
                      // Last Replaced Date with Icon
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16.0),
                          const SizedBox(width: 8.0),
                          Text(
                            'Last Replaced: ${part.lastReplacedDate ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      // Next Replaced Date with Icon
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 16.0),
                          const SizedBox(width: 8.0),
                          Text(
                            'Next Replaced: ${part.nextReplacedDate ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      // Replacement Interval with Icon
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16.0, color: Colors.orange),
                          const SizedBox(width: 8.0),
                          Text(
                            'Replacement Interval: ${part.replacementInterval ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      // Progress Indicator
                      LinearProgressIndicator(
                        value: part.lifespanProgress, // A value between 0.0 and 1.0
                        backgroundColor: Colors.grey[300],
                        color: _getProgressColor(part.lifespanProgress),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${(part.lifespanProgress! * 100).toStringAsFixed(0)}% Lifespan Remaining',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
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

  // Helper function to determine progress bar color
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