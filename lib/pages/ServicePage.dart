import 'package:flutter/material.dart';
import 'package:garagecom/pages/AddAndEditCars.dart';
import '../models/CarPart.dart';
import 'PartDetailsPage.dart';
import '../helpers/apiHelper.dart';
import 'package:intl/intl.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  bool isLoading = true;
  List<dynamic> userCars = [];
  int currentCarIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserCarsWithParts();
  }

  Future<void> fetchUserCarsWithParts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiHelper.get('api/Cars/GetUserCars', {});

      if (response['succeeded'] == true && response['parameters'] != null) {
        setState(() {
          userCars = response['parameters']['UserCars'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load cars data')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void goToAddPartPage() {
    if (userCars.isEmpty) return;

    final currentCarId = userCars[currentCarIndex]['carID'];

    // "-------------- goToAddPartPage was clicked, userCars[currentCarIndex = $");
    Navigator.of(context).pushNamed(
      '/AddPartPage',
      arguments: {'carId': currentCarId},
    ).then((_) {
      // Refresh data when coming back
      fetchUserCarsWithParts();
    });
  }

  void goToPartDetailsPage(dynamic part) {
    final carPart = CarPart(
      partName: part['part']['partName'],
      lastReplacedDate:
          DateFormat('MMM dd, yyyy').format(DateTime.parse(part['createdIn'])),
      nextReplacedDate: DateFormat('MMM dd, yyyy')
          .format(DateTime.parse(part['nextDueDate'])),
      replacementInterval: '${part['lifeTimeInterval']} Months',
      lifespanProgress:
          calculateLifespanProgress(part['createdIn'], part['nextDueDate']),
      carId: userCars[currentCarIndex]
          ['carID'], // Change from userCarID to carID
    );

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => PartDetailsPage(part: carPart),
      ),
    )
        .then((_) {
      // Refresh data when coming back
      fetchUserCarsWithParts();
    });
  }

  double calculateLifespanProgress(String createdIn, String nextDueDate) {
    final now = DateTime.now();
    final start = DateTime.parse(createdIn);
    final end = DateTime.parse(nextDueDate);

    final totalDuration = end.difference(start).inDays;
    final elapsedDuration = now.difference(start).inDays;

    if (totalDuration <= 0) return 0.0;

    final progress = 1.0 - (elapsedDuration / totalDuration);
    return progress.clamp(0.0, 1.0);
  }

  Color getProgressColor(double progress) {
    if (progress > 0.75) return Colors.green;
    if (progress > 0.5) return Colors.orange;
    return Colors.red;
  }

  IconData getPartIcon(String partName) {
    final lowerName = partName.toLowerCase();
    if (lowerName.contains('oil')) return Icons.opacity;
    if (lowerName.contains('filter')) return Icons.filter_alt;
    if (lowerName.contains('brake')) return Icons.warning;
    if (lowerName.contains('tire') || lowerName.contains('wheel'))
      return Icons.tire_repair;
    if (lowerName.contains('battery')) return Icons.battery_full;
    if (lowerName.contains('light') || lowerName.contains('bulb'))
      return Icons.lightbulb;
    return Icons.build;
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildAddCarsPage() {
      return ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed('/addAndEditCarsPage');
          },
          label: Text('Add Cars'),
          icon: Icon(Icons.add));
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Service'),
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car_outlined , color: Colors.white,),
              label: const Text('Add and edit cars'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAndEditCars(),
                  ),
                ).then((_) {
                  // Refresh data when coming back
                  fetchUserCarsWithParts();
                });
              },
              
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (userCars.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Service'),
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car_outlined , color: Colors.white,),
              label: const Text('Add and edit cars'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAndEditCars(),
                  ),
                ).then((_) {
                  // Refresh data when coming back
                  fetchUserCarsWithParts();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: Colors.white
              ),
              const SizedBox(height: 16),
              Text(
                'No cars found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAndEditCars(),
                    ),
                  );
                },
                icon: Icon(Icons.add_circle_outline, color: Colors.white), 
                label: const Text('Add Your  Car '),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentCar = userCars[currentCarIndex];
    final carParts = currentCar['parts'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service'),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.directions_car_outlined , color: Colors.white),
            label: const Text('Add and edit cars'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddAndEditCars(),
                ),
              ).then((_) {
                // Refresh data when coming back
                fetchUserCarsWithParts();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                  final brand = car['model']['brand']['brandName'];
                  final model = car['model']['modelName'];
                  final year = car['year'].toString();

                  return Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                return Icon(
                                  Icons.directions_car,
                                  size: 64,
                                  color: colorScheme.primary,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '$brand $model',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          year,
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
            Expanded(
              child: carParts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.handyman_outlined,
                            size: 64,
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.5),
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
                            icon: Icon(Icons.add, color: colorScheme.onPrimary),
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
                        final partName = part['part']['partName'];
                        final createdDate = DateTime.parse(part['createdIn']);
                        final nextDueDate = DateTime.parse(part['nextDueDate']);
                        final progress = calculateLifespanProgress(
                            part['createdIn'], part['nextDueDate']);

                        return GestureDetector(
                          onTap: () => goToPartDetailsPage(part),
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            color: colorScheme.surface,
                            shadowColor: colorScheme.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            getPartIcon(partName),
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            partName,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Renew $partName'),
                                              
                                              content: Text(
                                                  'Are you sure you want to mark this part as renewed today?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    // TODO: Implement API call to update renewal date
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              '$partName renewal scheduled')),
                                                    );
                                                    fetchUserCarsWithParts(); // Refresh data
                                                  },
                                                  child: Text('Confirm'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.refresh, size: 16, color: Colors.white),
                                        label: Text('Renew'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          textStyle: const TextStyle(
                                              fontSize: 12),
                                          minimumSize: const Size(80, 32),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    'Last Replaced:',
                                    DateFormat('MMM dd, yyyy')
                                        .format(createdDate),
                                    Colors.blue,
                                    theme,
                                  ),
                                  const SizedBox(height: 8.0),
                                  _buildInfoRow(
                                    Icons.calendar_month,
                                    'Next Replacement:',
                                    DateFormat('MMM dd, yyyy')
                                        .format(nextDueDate),
                                    Colors.red,
                                    theme,
                                  ),
                                  const SizedBox(height: 8.0),
                                  _buildInfoRow(
                                    Icons.schedule,
                                    'Interval:',
                                    '${part['lifeTimeInterval']} Months',
                                    Colors.orange,
                                    theme,
                                  ),
                                  const SizedBox(height: 16.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Lifespan Remaining',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getProgressColor(progress),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${(progress * 100).toStringAsFixed(0)}%',
                                              style: const TextStyle(
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
                                          value: progress,
                                          backgroundColor: Colors.grey[200],
                                          color: getProgressColor(progress),
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
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      Color iconColor, ThemeData theme) {
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
}
