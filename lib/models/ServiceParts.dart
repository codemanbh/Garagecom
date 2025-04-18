import 'package:garagecom/models/CarPart.dart';

class ServiceParts {
  List<CarPart> parts = [
    // 🚗 Car ID: 0 - Toyota Camry
    CarPart(
      carId: 0,
      partName: 'Air Filter',
      lastReplacedDate: '2023-06-10',
      nextReplacedDate: '2024-06-10',
      replacementInterval: 'Every 12 months',
      lifespanProgress: 0.8,
    ),
    CarPart(
      carId: 0,
      partName: 'Spark Plugs',
      lastReplacedDate: '2022-12-01',
      nextReplacedDate: '2025-12-01',
      replacementInterval: 'Every 3 years',
      lifespanProgress: 0.4,
    ),
    CarPart(
      carId: 0,
      partName: 'Cabin Filter',
      lastReplacedDate: '2024-01-01',
      nextReplacedDate: '2025-01-01',
      replacementInterval: 'Every 12 months',
      lifespanProgress: 1.0,
    ),

    // 🚘 Car ID: 1 - Honda Accord
    CarPart(
      carId: 1,
      partName: 'Brake Pads',
      lastReplacedDate: '2023-01-15',
      nextReplacedDate: '2024-01-15',
      replacementInterval: 'Every 12 months',
      lifespanProgress: 0.6,
    ),
    CarPart(
      carId: 1,
      partName: 'Transmission Fluid',
      lastReplacedDate: '2023-08-20',
      nextReplacedDate: '2026-08-20',
      replacementInterval: 'Every 3 years',
      lifespanProgress: 0.7,
    ),
    CarPart(
      carId: 1,
      partName: 'Wiper Blades',
      lastReplacedDate: '2024-02-15',
      nextReplacedDate: '2025-02-15',
      replacementInterval: 'Every 12 months',
      lifespanProgress: 0.95,
    ),

    // ⚡ Car ID: 2 - Tesla Model 3
    CarPart(
      carId: 2,
      partName: 'Cabin Air Filter',
      lastReplacedDate: '2023-04-01',
      nextReplacedDate: '2024-04-01',
      replacementInterval: 'Every 12 months',
      lifespanProgress: 0.5,
    ),
    CarPart(
      carId: 2,
      partName: 'Battery Coolant',
      lastReplacedDate: '2022-05-10',
      nextReplacedDate: '2026-05-10',
      replacementInterval: 'Every 4 years',
      lifespanProgress: 0.6,
    ),
    CarPart(
      carId: 2,
      partName: 'Tire Rotation',
      lastReplacedDate: '2024-03-01',
      nextReplacedDate: '2024-06-01',
      replacementInterval: 'Every 3 months',
      lifespanProgress: 0.3,
    ),
    CarPart(
      carId: 2,
      partName: 'Engine Oil', // Even EVs might log synthetic for reference
      lastReplacedDate: '2023-09-01',
      nextReplacedDate: '2024-03-01',
      replacementInterval: 'Every 6 months',
      lifespanProgress: 0.3,
    ),
  ];

  void savePartsList() {}
}