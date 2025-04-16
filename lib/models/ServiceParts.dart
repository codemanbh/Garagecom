import 'package:garagecom/models/CarPart.dart';

class ServiceParts {
  List<CarPart> parts = [
    CarPart(
      carId: 1,  // Added the required carId parameter
      partName: 'Brake Pads',
      lastReplacedDate: '2023-01-15',
      nextReplacedDate: '2024-01-15',
      replacementInterval: 'Every 12 months',
      lifespanProgress: 0.6, // 60% lifespan remaining
    ),
    CarPart(
      carId: 1,  // Added the required carId parameter
      partName: 'Engine Oil',
      lastReplacedDate: '2023-09-01',
      nextReplacedDate: '2024-03-01',
      replacementInterval: 'Every 6 months',
      lifespanProgress: 0.3, // 30% lifespan remaining
    ),
  ];

  void savePartsList() {}
}