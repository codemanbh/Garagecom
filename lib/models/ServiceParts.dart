import './CarPart.dart';

class ServiceParts {
  List<CarPart> parts = [
    CarPart(partName: 'Oil Filter', lastReplaced: 10),
    CarPart(partName: 'Air Filter', lastReplaced: 30),
    CarPart(partName: 'Brake Pads', lastReplaced: 100),
    CarPart(partName: 'Tires', lastReplaced: 10),
    CarPart(partName: 'Battery', lastReplaced: 20),
  ];

  void loudPartsList() {}
  void savePartsList() {}
}
