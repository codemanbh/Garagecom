import 'package:flutter/material.dart';
import 'package:garagecom/pages/ProfilePage.dart';
import '../components/CustomNavBar.dart';
import 'ProfileSettingsPage.dart'; // Import the ProfileSettingsPage

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = false; // Example state for dark mode toggle
    bool isNotificationsEnabled =
        true; // Example state for notifications toggle

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile section
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          const Divider(),
          // Dark mode toggle
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                // Handle dark mode toggle logic
              },
            ),
          ),
          const Divider(),
          // Notifications toggle
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Enable Notifications'),
            trailing: Switch(
              value: isNotificationsEnabled,
              onChanged: (value) {
                // Handle notifications toggle logic
              },
            ),
          ),
          const Divider(),
          // Account settings
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Account Settings'),
            onTap: () {
              // Navigate to account settings
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(),
    );
  }
}
