import 'package:flutter/material.dart';
import '../components/CustomNavBar.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  // Sample user data - this would come from your user profile/database
  final Map<String, String> userData = {
    'fullName': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+1 123 456 7890',
    'bio': 'Car enthusiast with 5+ years experience in mechanics.',
    'carName': 'My Ride',
    'carModel': 'Toyota Camry 2019',
    'mileage': '45,000 km',
  };

  bool isEditMode = false;
  
  // Controllers for editing text fields
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController bioController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController carNameController;
  late TextEditingController carModelController;
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
    carNameController = TextEditingController(text: userData['carName']);
    carModelController = TextEditingController(text: userData['carModel']);
    mileageController = TextEditingController(text: userData['mileage']);
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
    carModelController.dispose();
    mileageController.dispose();
    super.dispose();
  }

  void saveChanges() {
    // Here you would update the user data in your database
    setState(() {
      userData['fullName'] = nameController.text;
      userData['email'] = emailController.text;
      userData['phone'] = phoneController.text;
      userData['bio'] = bioController.text;
      userData['carName'] = carNameController.text;
      userData['carModel'] = carModelController.text;
      userData['mileage'] = mileageController.text;
      
      // Exit edit mode
      isEditMode = false;
    });
    
    // Show a confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  Widget buildInfoItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.primary),
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
                    fontWeight: FontWeight.w500,
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
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: colorScheme.primary),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
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
                  // Reset controllers to original values if cancelling edit
                  nameController.text = userData['fullName'] ?? '';
                  emailController.text = userData['email'] ?? '';
                  phoneController.text = userData['phone'] ?? '';
                  bioController.text = userData['bio'] ?? '';
                  carNameController.text = userData['carName'] ?? '';
                  carModelController.text = userData['carModel'] ?? '';
                  mileageController.text = userData['mileage'] ?? '';
                  passwordController.clear();
                  confirmPasswordController.clear();
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
            // User Avatar
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
                  // If you have user avatar, use this instead:
                  // backgroundImage: AssetImage('assets/images/avatar.png'),
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
            // User name as a title
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
            
            // Different views depending on edit mode
            if (!isEditMode) ...[
              // View mode - display information
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Car Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    buildInfoItem('Car Name', userData['carName'] ?? '', Icons.car_repair),
                    buildInfoItem('Car Model', userData['carModel'] ?? '', Icons.car_repair_sharp),
                    buildInfoItem('Mileage', userData['mileage'] ?? '', Icons.speed),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
              // Edit mode - show editable fields
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
                child: Text(
                  'Car Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              buildEditableField(
                label: 'Car Name',
                icon: Icons.car_repair,
                controller: carNameController,
              ),
              buildEditableField(
                label: 'Car Model',
                icon: Icons.car_repair_sharp,
                controller: carModelController,
              ),
              buildEditableField(
                label: 'Mileage',
                icon: Icons.speed,
                controller: mileageController,
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
}