import 'package:flutter/material.dart';
import '../components/CustomNavBar.dart';
import '../managers/CarInfo.dart';
import '../models/UserData.dart' as models;

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  // Car info manager
  final CarInfo carInfo = CarInfo();
  
  // List of cars
  List<models.Car> userCars = [];
  
  // Currently selected car for editing
  models.Car? currentEditingCar;
  
  // Sample user data
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
    ],
  };

  bool isEditMode = false;
  
  // Selected car brand, model, and year
  String? selectedCarBrand;
  String? selectedCarModel;
  String? selectedCarYear;
  
  // Controllers for editing text fields
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController bioController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController carNameController;
  late TextEditingController mileageController;
  
  @override
  void initState() {
    super.initState();
    // Initialize controllers with user data
    nameController = TextEditingController(text: userData['fullName']);
    emailController = TextEditingController(text: userData['email']);
    phoneController = TextEditingController(text: userData['phone']);
    bioController = TextEditingController(text: userData['bio']);
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    carNameController = TextEditingController();
    mileageController = TextEditingController();
    
    // Initialize user cars from userData
    userCars = (userData['cars'] as List<dynamic>)
        .map((carMap) => models.Car.fromMap(carMap as Map<String, dynamic>))
        .toList();
  }
  
  @override
  void dispose() {
    // Clean up controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    carNameController.dispose();
    mileageController.dispose();
    super.dispose();
  }

  void saveChanges() {
    // Save personal information
    userData['fullName'] = nameController.text;
    userData['email'] = emailController.text;
    userData['phone'] = phoneController.text;
    userData['bio'] = bioController.text;
    
    // Save cars information
    userData['cars'] = userCars.map((car) => car.toMap()).toList();
    
    // Save car changes if we're editing a car
    if (currentEditingCar != null) {
      saveCarChanges();
    }
    
    // Exit edit mode
    setState(() {
      isEditMode = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void addNewCar() {
    final newCar = models.Car(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      brand: '',
      model: '',
      year: '',
      nickname: '',
      mileage: '',
      isDefault: userCars.isEmpty, // First car is default
    );
    
    setState(() {
      currentEditingCar = newCar;
      userCars.add(newCar);
      
      // Initialize controllers for the new car
      selectedCarBrand = newCar.brand.isNotEmpty ? newCar.brand : null;
      selectedCarModel = newCar.model.isNotEmpty ? newCar.model : null;
      selectedCarYear = newCar.year.isNotEmpty ? newCar.year : null;
      carNameController.text = newCar.nickname;
      mileageController.text = newCar.mileage;
    });
  }
  
  void editCar(models.Car car) {
    setState(() {
      currentEditingCar = car;
      
      // Initialize controllers with car data
      selectedCarBrand = car.brand.isNotEmpty ? car.brand : null;
      selectedCarModel = car.model.isNotEmpty ? car.model : null;
      selectedCarYear = car.year.isNotEmpty ? car.year : null;
      carNameController.text = car.nickname;
      mileageController.text = car.mileage;
    });
  }
  
  void deleteCar(models.Car car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${car.nickname.isNotEmpty ? car.nickname : "${car.brand} ${car.model}"}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                userCars.remove(car);
                
                // If we deleted the default car, make another one default
                if (car.isDefault && userCars.isNotEmpty) {
                  userCars[0].isDefault = true;
                }
                
                // Clear current editing car if it was the deleted one
                if (currentEditingCar == car) {
                  currentEditingCar = null;
                }
              });
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Car removed successfully'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void setAsDefaultCar(models.Car car) {
    setState(() {
      // Remove default status from all cars
      for (final c in userCars) {
        c.isDefault = false;
      }
      
      // Set this car as default
      car.isDefault = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${car.nickname.isNotEmpty ? car.nickname : "${car.brand} ${car.model}"} set as default car'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  void saveCarChanges() {
    if (currentEditingCar != null) {
      setState(() {
        currentEditingCar!.brand = selectedCarBrand ?? '';
        currentEditingCar!.model = selectedCarModel ?? '';
        currentEditingCar!.year = selectedCarYear ?? '';
        currentEditingCar!.nickname = carNameController.text;
        currentEditingCar!.mileage = mileageController.text;
        
        currentEditingCar = null;
      });
    }
  }
  
  Widget buildCarCard(models.Car car) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final String carString = carInfo.formatCarDisplay(
      brand: car.brand,
      model: car.model,
      year: car.year,
      nickname: car.nickname,
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: car.isDefault 
            ? colorScheme.primary 
            : colorScheme.primary.withOpacity(0.2),
          width: car.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: car.isDefault 
                ? colorScheme.primary.withOpacity(0.1) 
                : Colors.transparent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: car.isDefault 
                    ? colorScheme.primary 
                    : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    carString,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (car.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (car.nickname.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nickname: ${car.nickname}',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (car.mileage.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mileage: ${car.mileage}',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          if (isEditMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => editCar(car),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  OutlinedButton.icon(
                    onPressed: () => deleteCar(car),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    label: Text(
                      'Delete',
                      style: TextStyle(color: colorScheme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const Spacer(),
                  
                  if (!car.isDefault)
                    TextButton(
                      onPressed: () => setAsDefaultCar(car),
                      child: Text(
                        'Set as Default',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget buildCarEditForm() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentEditingCar?.id.isEmpty == true ? 'Add New Car' : 'Edit Car',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          buildDropdown<String>(
            label: 'Car Brand',
            icon: Icons.directions_car,
            value: selectedCarBrand,
            items: carInfo.carBrands,
            onChanged: (newValue) {
              setState(() {
                selectedCarBrand = newValue;
                selectedCarModel = null;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a car brand';
              }
              return null;
            },
            itemDisplayName: (item) => item,
          ),
          
          if (selectedCarBrand != null)
            buildDropdown<String>(
              label: 'Car Model',
              icon: Icons.model_training,
              value: selectedCarModel,
              items: carInfo.getModelsForBrand(selectedCarBrand!),
              onChanged: (newValue) {
                setState(() {
                  selectedCarModel = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a car model';
                }
                return null;
              },
              itemDisplayName: (item) => item,
            ),
          
          buildDropdown<String>(
            label: 'Car Year',
            icon: Icons.calendar_today,
            value: selectedCarYear,
            items: carInfo.getCarYears(),
            onChanged: (newValue) {
              setState(() {
                selectedCarYear = newValue;
              });
            },
            validator: (value) {
              return null;
            },
            itemDisplayName: (item) => item,
          ),
          
          buildEditableField(
            label: 'Car Nickname (Optional)',
            icon: Icons.car_repair,
            controller: carNameController,
          ),
          
          buildEditableField(
            label: 'Mileage (Optional)',
            icon: Icons.speed,
            controller: mileageController,
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Checkbox(
                value: currentEditingCar?.isDefault ?? false,
                onChanged: (value) {
                  if (currentEditingCar != null && value == true) {
                    setState(() {
                      for (final car in userCars) {
                        car.isDefault = false;
                      }
                      currentEditingCar!.isDefault = true;
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Set as default car',
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    if (currentEditingCar != null && 
                        (currentEditingCar!.brand.isEmpty || 
                         currentEditingCar!.model.isEmpty)) {
                      userCars.remove(currentEditingCar);
                    }
                    currentEditingCar = null;
                  });
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (selectedCarBrand != null && selectedCarModel != null) {
                    saveCarChanges();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Car saved successfully'),
                        backgroundColor: colorScheme.primary,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select both car brand and model'),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                },
                child: const Text('Save Car'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
                if (!isEditMode) {
                  nameController.text = userData['fullName'] ?? '';
                  emailController.text = userData['email'] ?? '';
                  phoneController.text = userData['phone'] ?? '';
                  bioController.text = userData['bio'] ?? '';
                  passwordController.clear();
                  confirmPasswordController.clear();
                  currentEditingCar = null;
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                if (isEditMode)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              userData['fullName'] ?? 'User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              userData['email'] ?? 'Email',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            
            if (!isEditMode) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    buildInfoItem('Full Name', userData['fullName'] ?? '', Icons.person),
                    buildInfoItem('Email', userData['email'] ?? '', Icons.email),
                    buildInfoItem('Phone', userData['phone'] ?? '', Icons.phone),
                    buildInfoItem('Bio', userData['bio'] ?? '', Icons.info),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Cars',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${userCars.length} ${userCars.length == 1 ? 'car' : 'cars'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    userCars.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.directions_car_outlined,
                                    size: 48,
                                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No cars added yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your cars to enhance your experience',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: userCars.map((car) => buildCarCard(car)).toList(),
                          ),
                  ],
                ),
              ),
              
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isEditMode = true;
                  });
                },
                icon: const Icon(Icons.edit, color: Colors.white,),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 4,
                  shadowColor: colorScheme.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              buildEditableField(
                label: 'Full Name',
                icon: Icons.person,
                controller: nameController,
              ),
              buildEditableField(
                label: 'Email',
                icon: Icons.email,
                controller: emailController,
              ),
              buildEditableField(
                label: 'Phone Number',
                icon: Icons.phone,
                controller: phoneController,
              ),
              buildEditableField(
                label: 'Bio',
                icon: Icons.info,
                controller: bioController,
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cars',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: currentEditingCar == null ? addNewCar : null,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Car'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        disabledBackgroundColor: colorScheme.surfaceVariant,
                        disabledForegroundColor: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (currentEditingCar != null)
                buildCarEditForm()
              else if (userCars.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 48,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No cars added yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: addNewCar,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Your First Car'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: userCars.map((car) => buildCarCard(car)).toList(),
                ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              buildEditableField(
                label: 'New Password',
                icon: Icons.lock,
                controller: passwordController,
                obscureText: true,
              ),
              buildEditableField(
                label: 'Confirm New Password',
                icon: Icons.lock_outline,
                controller: confirmPasswordController,
                obscureText: true,
              ),
              
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: saveChanges,
                icon: const Icon(Icons.save, color: Colors.white,),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 4,
                  shadowColor: colorScheme.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }

  // Widget to build an info item in view mode
  Widget buildInfoItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build an editable text field
  Widget buildEditableField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: colorScheme.primary.withOpacity(0.7),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, 
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build a dropdown
  Widget buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    required String Function(T) itemDisplayName,
    required String? Function(T?) validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.5),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<T>(
                value: value,
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    icon,
                    color: colorScheme.primary.withOpacity(0.7),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                isExpanded: true,
                hint: Text(
                  'Select $label',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                ),
                dropdownColor: colorScheme.surfaceContainerHigh,
                validator: validator,
                items: items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      itemDisplayName(item),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}