import 'package:flutter/material.dart';
import '../managers/CarInfo.dart';
import '../models/UserData.dart';
import '../managers/UserService.dart';
import '../helpers/apiHelper.dart';

class AddAndEditCars extends StatefulWidget {
  const AddAndEditCars({super.key});

  @override
  State<AddAndEditCars> createState() => _AddAndEditCarsState();
}

class _AddAndEditCarsState extends State<AddAndEditCars> {
  // Car info manager
  final CarInfo carInfo = CarInfo();

  // API data
  Map<String, dynamic>? userData;
  List<dynamic> userCars = [];

  // Add these variables to hold API data for brands and models
  List<dynamic> carBrands = [];
  List<dynamic> carModels = [];
  bool isBrandsLoading = false;
  bool isModelsLoading = false;

  // Currently selected car for editing
  Map<String, dynamic>? currentEditingCar;

  bool isEditMode = false;
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';

  // Selected car brand, model, and year
  int? selectedBrandId;
  String? selectedBrandName;
  int? selectedModelId;
  String? selectedModelName;
  int? selectedYear;

  // Controllers for editing text fields
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController carNameController;
  late TextEditingController mileageController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    carNameController = TextEditingController();
    mileageController = TextEditingController();

    // Load user data
    loadUserData();

    // Load car brands from API
    loadBrands();
  }

  @override
  void dispose() {
    // Clean up controllers
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    carNameController.dispose();
    mileageController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      // Fetch user profile
      final profileResponse = await UserService.getUserProfile();

      // Fetch user cars
      final carsResponse = await UserService.getUserCars();

      setState(() {
        userData = profileResponse['parameters']['User'];
        userCars = carsResponse['parameters']['UserCars'];

        // Update controllers with user data
        if (userData != null) {
          firstNameController.text = userData!['FirstName'] ?? '';
          lastNameController.text = userData!['LastName'] ?? '';
          usernameController.text = userData!['userName'] ?? '';
          emailController.text = userData!['email'] ?? '';
          phoneController.text = userData!['phoneNumber'] ?? '';
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = e.toString();
      });
    }
  }

  void _handleLogout() {
    ApiHelper.post('/api/Proile/Logout', {});
    ApiHelper.handleAnAuthorized();
  }

  Future<void> updateProfile() async {
    if (userData == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Update user data with edited values
      final updatedUserData = {
        'userID': userData!['userID'],
        'userName': usernameController.text,
        'firstName': firstNameController.text,
        'lastName': firstNameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
      };

      // Call API to update profile
      final response = await UserService.updateUserProfile(updatedUserData);

      setState(() {
        isLoading = false;
        isEditMode = false;
        userData = response['parameters']['User'] ?? userData;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void addNewCar() {
    setState(() {
      currentEditingCar = {
        'carID': 0,
        'year': DateTime.now().year,
        'nickname': '',
        'kilos': 0,
        'model': {
          'modelID': 0,
          'modelName': '',
          'brand': {'brandID': 0, 'brandName': ''}
        }
      };

      selectedBrandId = null;
      selectedBrandName = null;
      selectedModelId = null;
      selectedModelName = null;
      selectedYear = DateTime.now().year;
      carNameController.text = '';
      mileageController.text = '0';

      // Clear models list since no brand is selected
      carModels = [];
    });
  }

  void editCar(Map<String, dynamic> car) {
    setState(() {
      currentEditingCar = Map<String, dynamic>.from(car);

      // Initialize controllers with car data
      selectedBrandId = car['model']['brand']['brandID'];
      selectedBrandName = car['model']['brand']['brandName'];
      selectedModelId = car['model']['modelID'];
      selectedModelName = car['model']['modelName'];
      selectedYear = car['year'];
      carNameController.text = car['nickname'] ?? '';
      mileageController.text = car['kilos']?.toString() ?? '0';

      // Load models for this brand
      loadModels(selectedBrandId!);
    });
  }

  Future<void> saveCarChanges() async {
    if (currentEditingCar == null ||
        selectedBrandId == null ||
        selectedModelId == null ||
        selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required car information'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Update car with new values
      currentEditingCar!['year'] = selectedYear;
      currentEditingCar!['nickname'] = carNameController.text;
      currentEditingCar!['kilos'] = int.tryParse(mileageController.text) ?? 0;
      currentEditingCar!['model'] = {
        'modelID': selectedModelId,
        'modelName': selectedModelName,
        'brand': {'brandID': selectedBrandId, 'brandName': selectedBrandName}
      };

      // Print the whole car object for debugging
      print('Saving car: $currentEditingCar');

      // Save whether this is an add or update operation before clearing the car
      final bool isNewCar = currentEditingCar!['carID'] == 0;

      Map<String, dynamic> response;

      if (isNewCar) {
        // This is a new car
        response = await UserService.addCar(currentEditingCar!);
      } else {
        // This is an existing car
        response = await UserService.updateCar(currentEditingCar!);
      }

      // Reload cars
      final carsResponse = await UserService.getUserCars();

      setState(() {
        userCars = carsResponse['parameters']['UserCars'];
        currentEditingCar = null;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Car successfully ${isNewCar ? 'added' : 'updated'}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> deleteCar(Map<String, dynamic> car) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to delete "${car['nickname'] != null && car['nickname'].toString().isNotEmpty ? car['nickname'] : "${car['model']['brand']['brandName']} ${car['model']['modelName']}"}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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

    if (confirmed == true) {
      setState(() {
        isLoading = true;
      });

      try {
        await UserService.deleteCar(car['carID']);

        // Reload cars
        final carsResponse = await UserService.getUserCars();

        setState(() {
          userCars = carsResponse['parameters']['UserCars'];
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Car deleted successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget buildCarCard(Map<String, dynamic> car) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final brand = car['model']['brand']['brandName'];
    final model = car['model']['modelName'];
    final year = car['year']?.toString() ?? '';
    final nickname = car['nickname'] ?? '';
    final kilos = car['kilos'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$year $brand $model',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (nickname.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nickname: $nickname',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (kilos > 0) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mileage: $kilos km',
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
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> loadBrands() async {
    setState(() {
      isBrandsLoading = true;
      carBrands = []; // Clear existing brands
    });

    try {
      final response = await UserService.getCarBrands();

      if (response['succeeded'] == true &&
          response['parameters'] != null &&
          response['parameters']['Brands'] != null) {
        final brands = response['parameters']['Brands'];
        print('Raw brands data: $brands');

        setState(() {
          carBrands = brands;
          isBrandsLoading = false;
        });

        print('Loaded ${carBrands.length} brands');

        // Print each brand for debugging
        for (var brand in carBrands) {
          print(
              'Brand ID: ${brand['brandID']}, Brand Name: ${brand['brandName']}');
        }
      } else {
        setState(() {
          isBrandsLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load car brands'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isBrandsLoading = false;
      });

      print('Error loading brands: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading brands: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> loadModels(int brandId) async {
    setState(() {
      isModelsLoading = true;
      carModels = []; // Clear existing models
      selectedModelId = null;
      selectedModelName = null;
    });

    try {
      final response = await UserService.getCarModels(brandId);

      if (response['succeeded'] == true &&
          response['parameters'] != null &&
          response['parameters']['Models'] != null) {
        final models = response['parameters']['Models'];
        print('Raw models data: $models');

        setState(() {
          carModels = models;
          isModelsLoading = false;
        });

        print('Loaded ${carModels.length} models for brand ID $brandId');

        // Print each model for debugging
        for (var model in carModels) {
          print(
              'Model ID: ${model['modelID']}, Model Name: ${model['modelName']}');
        }
      } else {
        setState(() {
          isModelsLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load car models'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isModelsLoading = false;
      });

      print('Error loading models: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading models: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cars'),
        actions: [
          if (!isLoading && !isError)
            IconButton(
              icon: Icon(isEditMode ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  isEditMode = !isEditMode;
                  if (!isEditMode) {
                    // Reset fields to current values
                    if (userData != null) {
                      firstNameController.text = userData!['firstName'] ?? '';
                      lastNameController.text = userData!['lastName'] ?? '';
                      usernameController.text = userData!['userName'] ?? '';
                      emailController.text = userData!['email'] ?? '';
                      phoneController.text = userData!['phoneNumber'] ?? '';
                    }
                    currentEditingCar = null;
                  }
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: loadUserData,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isEditMode) ...[
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow
                                .withOpacity(0.5),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withOpacity(0.5),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No cars added yet',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Add your cars to enhance your experience',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: userCars
                                          .map<Widget>(
                                              (car) => buildCarCard(car))
                                          .toList(),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isEditMode = true;
                            });
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          label: const Text('Edit Cars'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
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
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'My Cars',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: currentEditingCar == null
                                        ? addNewCar
                                        : null,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Car'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          colorScheme.primaryContainer,
                                      foregroundColor:
                                          colorScheme.onPrimaryContainer,
                                      disabledBackgroundColor:
                                          colorScheme.surfaceVariant,
                                      disabledForegroundColor: colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (currentEditingCar != null)
                                buildCarEditForm()
                              else if (userCars.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.directions_car_outlined,
                                          size: 48,
                                          color: colorScheme.onSurfaceVariant
                                              .withOpacity(0.5),
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
                                          label:
                                              const Text('Add Your First Car'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                colorScheme.primary,
                                            foregroundColor:
                                                colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: userCars
                                      .map<Widget>((car) => buildCarCard(car))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  // Helper methods for UI components
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
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
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
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
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
            currentEditingCar!['carID'] == 0 ? 'Add New Car' : 'Edit Car',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Car brand selection - using API data
          isBrandsLoading
              ? const Center(child: CircularProgressIndicator())
              : buildDropdown<Map<String, dynamic>>(
                  label: 'Car Brand',
                  icon: Icons.directions_car,
                  value: selectedBrandId != null && carBrands.isNotEmpty
                      ? carBrands.cast<Map<String, dynamic>>().firstWhere(
                            (brand) => brand['brandID'] == selectedBrandId,
                            orElse: () => <String, dynamic>{},
                          )
                      : null,
                  items: carBrands.cast<Map<String, dynamic>>(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      print('Selected brand: $newValue');
                      setState(() {
                        selectedBrandId = newValue['brandID'];
                        selectedBrandName = newValue['brandName'];
                        selectedModelId = null;
                        selectedModelName = null;

                        // Load models for this brand
                        loadModels(selectedBrandId!);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a car brand';
                    }
                    return null;
                  },
                  itemDisplayName: (item) =>
                      item['brandName'] ?? 'Unknown Brand',
                ),

          // Car model selection - using API data
          buildDropdown<Map<String, dynamic>>(
            label: 'Car Model',
            icon: Icons.model_training,
            value: selectedModelId != null && carModels.isNotEmpty
                ? carModels.cast<Map<String, dynamic>>().firstWhere(
                      (model) => model['modelID'] == selectedModelId,
                      orElse: () => <String, dynamic>{},
                    )
                : null,
            items: carModels.cast<Map<String, dynamic>>(),
            onChanged: selectedBrandId == null || isModelsLoading
                ? null // Disable dropdown if no brand selected or models are loading
                : (newValue) {
                    if (newValue != null) {
                      print('Selected model: $newValue');
                      setState(() {
                        selectedModelId = newValue['modelID'];
                        selectedModelName = newValue['modelName'];
                      });
                    }
                  },
            validator: (value) {
              if (selectedBrandId != null && value == null) {
                return 'Please select a car model';
              }
              return null;
            },
            itemDisplayName: (item) => item['modelName'] ?? 'Unknown Model',
            isEnabled: selectedBrandId != null && !isModelsLoading,
            isLoading: isModelsLoading,
          ),

          // Car year selection
          buildDropdown<int>(
            label: 'Car Year',
            icon: Icons.calendar_today,
            value: selectedYear,
            items: List.generate(15, (index) => DateTime.now().year - index),
            onChanged: (newValue) {
              setState(() {
                selectedYear = newValue;
              });
            },
            validator: (value) {
              return null;
            },
            itemDisplayName: (item) => item.toString(),
            isEnabled: true,
            isLoading: false,
          ),

          // Car nickname
          buildEditableField(
            label: 'Car Nickname (Optional)',
            icon: Icons.car_repair,
            controller: carNameController,
          ),

          // Car mileage
          buildEditableField(
            label: 'Mileage (km)',
            icon: Icons.speed,
            controller: mileageController,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
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
                onPressed: selectedBrandId != null &&
                        selectedModelId != null &&
                        selectedYear != null
                    ? saveCarChanges
                    : null, // Disable button if required fields are not filled
                child: Text(
                    currentEditingCar!['carID'] == 0 ? 'Add Car' : 'Save Car'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor: colorScheme.surfaceVariant,
                  disabledForegroundColor:
                      colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required Function(T?)? onChanged,
    required String Function(T) itemDisplayName,
    required String? Function(T?) validator,
    bool isEnabled = true,
    bool isLoading = false,
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
              color: isEnabled
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isEnabled
                  ? theme.colorScheme.surface
                  : theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled
                    ? colorScheme.outline
                    : colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 48,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: value,
                      isExpanded: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: isEnabled
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      hint: Text(
                        isEnabled
                            ? 'Select ${label.toLowerCase()}'
                            : 'Select a brand first',
                        style: TextStyle(
                          color: isEnabled
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                      items: items.map((T item) {
                        return DropdownMenuItem<T>(
                          value: item,
                          child: Text(itemDisplayName(item)),
                        );
                      }).toList(),
                      onChanged: isEnabled ? onChanged : null,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      dropdownColor: theme.colorScheme.surface,
                    ),
                  ),
          ),
          if (validator(value) != null && isEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                validator(value) ?? '',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Add this utility method to help with firstWhere
  Map<String, dynamic>? findById(
      List<dynamic> items, String idField, int idValue) {
    if (items.isEmpty) return null;

    try {
      // Create a properly-typed copy of items to avoid issues
      final typedItems = List<Map<String, dynamic>>.from(items);

      // Find item by ID, returning empty map if not found (not null)
      final item = typedItems.firstWhere(
        (item) => item[idField] == idValue,
        orElse: () => <String, dynamic>{},
      );

      // Only return the item if it's not empty (has keys)
      return item.isNotEmpty ? item : null;
    } catch (e) {
      print('Error finding item: $e');
      return null;
    }
  }
}
