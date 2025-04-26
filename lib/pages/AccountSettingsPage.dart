import 'package:flutter/material.dart';
import '../components/CustomNavBar.dart';
import '../managers/CarInfo.dart';
import '../models/UserData.dart';
import '../managers/UserService.dart';
import '../helpers/apiHelper.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  // Car info manager
  final CarInfo carInfo = CarInfo();

  // API data
  Map<String, dynamic>? userData;
  List<dynamic> userCars = [];

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
          firstNameController.text = userData!['firstName'] ?? '';
          lastNameController.text = userData!['lastName'] ?? '';
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
        'lastName': lastNameController.text,
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
        'carModel': {
          'carModelID': 0,
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
    });
  }

  void editCar(Map<String, dynamic> car) {
    setState(() {
      currentEditingCar = Map<String, dynamic>.from(car);

      // Initialize controllers with car data
      selectedBrandId = car['carModel']['brand']['brandID'];
      selectedBrandName = car['carModel']['brand']['brandName'];
      selectedModelId = car['carModel']['carModelID'];
      selectedModelName = car['carModel']['modelName'];
      selectedYear = car['year'];
      carNameController.text = car['nickname'] ?? '';
      mileageController.text = car['kilos']?.toString() ?? '0';
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
      currentEditingCar!['carModel'] = {
        'carModelID': selectedModelId,
        'modelName': selectedModelName,
        'brand': {'brandID': selectedBrandId, 'brandName': selectedBrandName}
      };

      // Print the whole car object for debugging
      print('Saving car: $currentEditingCar');

      Map<String, dynamic> response;

      if (currentEditingCar!['carID'] == 0) {
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
          content: Text(
              'Car successfully ${currentEditingCar!['carID'] == 0 ? 'added' : 'updated'}'),
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
            'Are you sure you want to delete "${car['nickname'] != null && car['nickname'].toString().isNotEmpty ? car['nickname'] : "${car['carModel']['brand']['brandName']} ${car['carModel']['modelName']}"}"?'),
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

    final brand = car['carModel']['brand']['brandName'];
    final model = car['carModel']['modelName'];
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
    try {
      final response = await UserService.getCarBrands();
      // Handle the brands data as needed
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading brands: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> loadModels(int brandId) async {
    try {
      final response = await UserService.getCarModels(brandId);
      // Handle the models data as needed
    } catch (e) {
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
        title: const Text('Account Settings'),
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
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: colorScheme.primaryContainer,
                            backgroundImage: userData != null &&
                                    userData!['profilePicture'] != null
                                ? NetworkImage(
                                    '${ApiHelper.mainDomain}api/Users/GetProfilePicture?filename=${userData!['profilePicture']}')
                                : null,
                            child: userData == null ||
                                    userData!['profilePicture'] == null
                                ? Icon(
                                    Icons.person,
                                    size: 80,
                                    color: colorScheme.onPrimaryContainer,
                                  )
                                : null,
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
                        userData != null
                            ? '${userData!['firstName'] ?? ''} ${userData!['lastName'] ?? ''}'
                            : 'User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        userData != null
                            ? userData!['email'] ?? 'Email'
                            : 'Email',
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
                              buildInfoItem(
                                  'Username',
                                  userData != null
                                      ? userData!['userName'] ?? ''
                                      : '',
                                  Icons.account_circle),
                              buildInfoItem(
                                  'Full Name',
                                  userData != null
                                      ? '${userData!['firstName'] ?? ''} ${userData!['lastName'] ?? ''}'
                                      : '',
                                  Icons.person),
                              buildInfoItem(
                                  'Email',
                                  userData != null
                                      ? userData!['email'] ?? ''
                                      : '',
                                  Icons.email),
                              buildInfoItem(
                                  'Phone',
                                  userData != null
                                      ? userData!['phoneNumber'] ?? ''
                                      : '',
                                  Icons.phone),
                            ],
                          ),
                        ),
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
                          label: const Text('Edit Profile'),
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
                        // Edit mode UI
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
                                label: 'Username',
                                icon: Icons.account_circle,
                                controller: usernameController,
                              ),
                              buildEditableField(
                                label: 'First Name',
                                icon: Icons.person_outline,
                                controller: firstNameController,
                              ),
                              buildEditableField(
                                label: 'Last Name',
                                icon: Icons.person,
                                controller: lastNameController,
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
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: updateProfile,
                                child: const Text('Save Profile'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

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
      bottomNavigationBar: const CustomNavBar(),
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

    // For simplicity, we're using the CarInfo manager in this example
    // In a real app, you would fetch brands and models from API

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

          // Car brand selection
          buildDropdown<String>(
            label: 'Car Brand',
            icon: Icons.directions_car,
            value: selectedBrandName,
            items: carInfo.carBrands,
            onChanged: (newValue) {
              setState(() {
                selectedBrandName = newValue;
                selectedBrandId =
                    carInfo.carBrands.indexOf(newValue!) + 1; // Mock ID
                selectedModelName = null;
                selectedModelId = null;
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

          // Car model selection
          if (selectedBrandName != null)
            buildDropdown<String>(
              label: 'Car Model',
              icon: Icons.model_training,
              value: selectedModelName,
              items: carInfo.getModelsForBrand(selectedBrandName!),
              onChanged: (newValue) {
                setState(() {
                  selectedModelName = newValue;
                  selectedModelId = carInfo
                          .getModelsForBrand(selectedBrandName!)
                          .indexOf(newValue!) +
                      1; // Mock ID
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
                onPressed: saveCarChanges,
                child: Text(
                    currentEditingCar!['carID'] == 0 ? 'Add Car' : 'Save Car'),
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
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                hint: Text('Select ${label.toLowerCase()}'),
                items: items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemDisplayName(item)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          if (validator(value) != null)
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
}
