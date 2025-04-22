class CarInfo {
  final List<String> carBrands = [
    'Toyota',
    'Honda',
    'Ford',
    'Chevrolet',
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Volkswagen',
    'Nissan',
    'Hyundai',
    'Kia',
    'Mazda',
    'Subaru',
    'Lexus',
    'Jeep',
    'Tesla',
  ];

  Map<String, List<String>> brandModels = {
    'Toyota': ['Camry', 'Corolla', 'Rav4', 'Highlander', 'Tacoma', 'Tundra', 'Sienna', 'Prius'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot', 'Odyssey', 'HR-V', 'Ridgeline', 'Fit'],
    'Ford': ['F-150', 'Escape', 'Explorer', 'Edge', 'Mustang', 'Ranger', 'Expedition', 'Bronco'],
    'Chevrolet': ['Silverado', 'Equinox', 'Malibu', 'Traverse', 'Tahoe', 'Camaro', 'Colorado', 'Suburban'],
    'BMW': ['3 Series', '5 Series', 'X3', 'X5', '7 Series', 'X1', 'X7', 'M3'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'GLE', 'A-Class', 'GLA', 'G-Wagon'],
    'Audi': ['A4', 'A6', 'Q5', 'Q7', 'A3', 'Q3', 'A8', 'e-tron'],
    'Volkswagen': ['Jetta', 'Passat', 'Tiguan', 'Atlas', 'Golf', 'ID.4', 'Taos', 'Arteon'],
    'Nissan': ['Altima', 'Sentra', 'Rogue', 'Murano', 'Pathfinder', 'Frontier', 'Titan', 'Kicks'],
    'Hyundai': ['Elantra', 'Sonata', 'Tucson', 'Santa Fe', 'Kona', 'Palisade', 'Venue', 'Ioniq'],
    'Kia': ['Forte', 'Optima', 'Sportage', 'Sorento', 'Telluride', 'Soul', 'Niro', 'Stinger'],
    'Mazda': ['Mazda3', 'Mazda6', 'CX-5', 'CX-9', 'CX-30', 'MX-5 Miata', 'CX-3', 'CX-50'],
    'Subaru': ['Outback', 'Forester', 'Impreza', 'Crosstrek', 'Ascent', 'Legacy', 'WRX', 'BRZ'],
    'Lexus': ['RX', 'ES', 'NX', 'IS', 'GX', 'UX', 'LS', 'LC'],
    'Jeep': ['Wrangler', 'Grand Cherokee', 'Cherokee', 'Compass', 'Renegade', 'Gladiator', 'Wagoneer', 'Grand Wagoneer'],
    'Tesla': ['Model 3', 'Model Y', 'Model S', 'Model X', 'Cybertruck', 'Roadster'],
  };

  List<String> getModelsForBrand(String brand) {
    return brandModels[brand] ?? [];
  }

  List<String> getCarYears() {
    final currentYear = DateTime.now().year;
    final years = <String>[];
    
    for (int i = currentYear + 1; i >= 1990; i--) {
      years.add(i.toString());
    }
    
    return years;
  }

  String formatCarDisplay({
    required String brand,
    required String model,
    required String year,
    required String nickname,
  }) {
    if (brand.isEmpty && model.isEmpty) {
      return nickname.isNotEmpty ? nickname : 'New Car';
    }
    
    String displayName = '';
    
    if (brand.isNotEmpty) {
      displayName += brand;
    }
    
    if (model.isNotEmpty) {
      displayName += displayName.isNotEmpty ? ' $model' : model;
    }
    
    if (year.isNotEmpty) {
      displayName = '$year $displayName';
    }
    
    return displayName;
  }
}

// Add this class to manage car data
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