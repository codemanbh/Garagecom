// Update the userData map in _AccountSettingsPageState
final Map<String, dynamic> userData = {
  'fullName': 'John Doe',
  'email': 'john.doe@example.com',
  'phone': '+1 123 456 7890',
  'bio': 'Car enthusiast with 5+ years experience in mechanics.',
  'cars': [
    {
      'id': '1',
      'brand': 'Toyota',
      'model': 'Camry',
      'year': '2019',
      'nickname': 'My Ride',
      'mileage': '45,000 km',
      'isDefault': true,
    },
    // Additional cars can be added here
  ],
};

class Car {
  String id;
  String brand;
  String model;
  String year;
  String nickname;
  String mileage;
  bool isDefault;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    this.nickname = '',
    this.mileage = '',
    this.isDefault = false,
  });

  // Create a car object from JSON/Map
  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? '',
      nickname: map['nickname'] ?? '',
      mileage: map['mileage'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  // Convert car object to JSON/Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'nickname': nickname,
      'mileage': mileage,
      'isDefault': isDefault,
    };
  }
}