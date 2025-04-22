class CarInfo {
  // Singleton pattern
  static final CarInfo _instance = CarInfo._internal();
  
  factory CarInfo() {
    return _instance;
  }
  
  CarInfo._internal();
  
  // Car brand data
  final Map<String, List<String>> carModels = {
    'Toyota': ['Camry', 'Corolla', 'RAV4', 'Highlander', 'Tacoma', 'Tundra', 'Prius'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot', 'Odyssey', 'HR-V', 'Ridgeline'],
    'Ford': ['F-150', 'Mustang', 'Explorer', 'Escape', 'Edge', 'Ranger', 'Bronco'],
    'Chevrolet': ['Silverado', 'Equinox', 'Malibu', 'Tahoe', 'Traverse', 'Suburban', 'Camaro'],
    'Nissan': ['Altima', 'Sentra', 'Rogue', 'Pathfinder', 'Murano', 'Maxima', 'Frontier'],
    'BMW': ['3 Series', '5 Series', 'X3', 'X5', '7 Series', 'M3', 'M5'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'GLE', 'A-Class', 'G-Wagon'],
    'Audi': ['A4', 'A6', 'Q5', 'Q7', 'A3', 'Q3', 'e-tron'],
    'Hyundai': ['Elantra', 'Sonata', 'Tucson', 'Santa Fe', 'Kona', 'Palisade', 'Venue'],
    'Kia': ['Forte', 'Optima', 'Sorento', 'Sportage', 'Telluride', 'Soul', 'Seltos'],
    'Volkswagen': ['Jetta', 'Passat', 'Tiguan', 'Atlas', 'Golf', 'Taos', 'ID.4'],
    'Subaru': ['Outback', 'Forester', 'Crosstrek', 'Impreza', 'Legacy', 'Ascent', 'WRX'],
    'Lexus': ['RX', 'ES', 'NX', 'IS', 'GX', 'UX', 'LS'],
    'Mazda': ['Mazda3', 'Mazda6', 'CX-5', 'CX-9', 'MX-5 Miata', 'CX-30', 'CX-3'],
    'Jeep': ['Wrangler', 'Grand Cherokee', 'Cherokee', 'Compass', 'Gladiator', 'Renegade', 'Grand Wagoneer'],
    'Ram': ['1500', '2500', '3500', 'ProMaster', 'ProMaster City'],
    'GMC': ['Sierra', 'Yukon', 'Terrain', 'Acadia', 'Canyon', 'Savana'],
    'Dodge': ['Charger', 'Challenger', 'Durango', 'Journey', 'Grand Caravan'],
    'Chrysler': ['Pacifica', '300', 'Voyager'],
    'Buick': ['Enclave', 'Encore', 'Envision', 'Regal'],
    'Cadillac': ['Escalade', 'XT5', 'CT5', 'XT4', 'CT4', 'XT6'],
    'Acura': ['RDX', 'MDX', 'TLX', 'ILX', 'NSX', 'RLX'],
    'Infiniti': ['Q50', 'QX60', 'QX80', 'QX50', 'Q60', 'QX30'],
    'Lincoln': ['Navigator', 'Corsair', 'Aviator', 'Nautilus', 'MKZ'],
    'Volvo': ['XC90', 'XC60', 'S60', 'V60', 'XC40', 'S90'],
    'Land Rover': ['Range Rover', 'Discovery', 'Defender', 'Range Rover Sport', 'Range Rover Evoque', 'Range Rover Velar'],
    'Porsche': ['911', 'Cayenne', 'Macan', 'Panamera', 'Taycan', '718'],
    'Tesla': ['Model 3', 'Model Y', 'Model S', 'Model X', 'Cybertruck'],
  };
  
  // Get available car brands
  List<String> get carBrands => carModels.keys.toList();
  
  // Get models for a specific brand
  List<String> getModelsForBrand(String brand) {
    return carModels[brand] ?? [];
  }
  
  // Get available car years (last 30 years)
  List<String> getCarYears() {
    final currentYear = DateTime.now().year;
    return List.generate(30, (index) => (currentYear - index).toString());
  }
  
  // Format car details into a display string
  String formatCarDisplay({String? brand, String? model, String? year, String? nickname}) {
    if (brand != null && brand.isNotEmpty && model != null && model.isNotEmpty) {
      String carString = '$brand $model';
      if (year != null && year.isNotEmpty) {
        carString += ' $year';
      }
      return carString;
    } else if (nickname != null && nickname.isNotEmpty) {
      return nickname;
    }
    return 'No car information';
  }
}