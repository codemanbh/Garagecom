import 'package:flutter/material.dart';
import '../components/CustomNavBar.dart';
import '../models/CarPart.dart';
import '../models/ServiceParts.dart';
import 'PartDetailsPage.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final ServiceParts serviceParts = ServiceParts();
  int currentCarIndex = 0;

  // Sample cars data - replace with your actual data source
  final List<Map<String, dynamic>> userCars = [
    {
      'name': 'Toyota Camry',
      'year': '2019',
      'icon': Icons.directions_car,
      'color': Colors.blue,
    },
    {
      'name': 'Honda Accord',
      'year': '2020',
      'icon': Icons.time_to_leave,
      'color': Colors.red,
    },
    {
      'name': 'Tesla Model 3',
      'year': '2022',
      'icon': Icons.electric_car,
      'color': Colors.green,
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    final List<CarPart> carParts = serviceParts.parts;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: goToAddPartPage,
            tooltip: 'Add new part',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Car selection carousel - reduced height by a small amount
            Container(
              height: 190,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withOpacity(0.7),
                    colorScheme.primaryContainer.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: PageView.builder(
                itemCount: userCars.length,
                onPageChanged: (index) {
                  setState(() {
                    currentCarIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final car = userCars[index];
                  return Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Car image - reduced height slightly
                        Container(
                          height: 90,
                          width: 500,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/Made with insMind-car-icon-3657902_1280.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $error');
                                return Container(
                                  
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Car name and year
                        Text(
                          car['name'] ?? 'Unknown Car',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          car['year'] ?? 'Unknown Year',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicator dots - reduced padding
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  userCars.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentCarIndex == index ? 12 : 8,
                    height: currentCarIndex == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color: currentCarIndex == index
                          ? colorScheme.primary
                          : colorScheme.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // Maintenance schedule title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.build_circle,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Maintenance Schedule',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Parts list
            Expanded(
              child: carParts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.handyman_outlined,
                            size: 64,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No parts added yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: goToAddPartPage,
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Part'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: carParts.length,
                      itemBuilder: (context, index) {
                        final part = carParts[index];
                        return GestureDetector(
                          onTap: () => goToPartDetailsPage(part),
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Part name
                                  Row(
                                    children: [
                                      Icon(
                                        _getPartIcon(part.partName ?? ''),
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        part.partName ?? '',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Last Replaced Date with Icon
                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    'Last Replaced:',
                                    part.lastReplacedDate ?? 'N/A',
                                    Colors.blue,
                                    theme,
                                  ),
                                  const SizedBox(height: 8.0),

                                  // Next Replaced Date with Icon
                                  _buildInfoRow(
                                    Icons.calendar_month,
                                    'Next Replacement:',
                                    part.nextReplacedDate ?? 'N/A',
                                    Colors.red,
                                    theme,
                                  ),
                                  const SizedBox(height: 8.0),

                                  // Replacement Interval with Icon
                                  _buildInfoRow(
                                    Icons.schedule,
                                    'Interval:',
                                    part.replacementInterval ?? 'N/A',
                                    Colors.orange,
                                    theme,
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Progress Indicator
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Lifespan Remaining',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
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
                                              '${(part.lifespanProgress! * 100).toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: part.lifespanProgress,
                                          backgroundColor: Colors.grey[200],
                                          color: _getProgressColor(part.lifespanProgress),
                                          minHeight: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
        onPressed: goToAddPartPage,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: iconColor),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4.0),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

  // Helper function to get appropriate icon for part
  IconData _getPartIcon(String partName) {
    final lowerName = partName.toLowerCase();
    if (lowerName.contains('oil')) return Icons.opacity;
    if (lowerName.contains('filter')) return Icons.filter_alt;
    if (lowerName.contains('brake')) return Icons.warning;
    if (lowerName.contains('tire') || lowerName.contains('wheel')) return Icons.tire_repair;
    if (lowerName.contains('battery')) return Icons.battery_full;
    if (lowerName.contains('light') || lowerName.contains('bulb')) return Icons.lightbulb;
    // Default icon
    return Icons.build;
  }
}
