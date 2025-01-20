import 'package:flutter/material.dart';
import '../components/CustomNavBar.dart';

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
          // const Divider(),
          // // Language selection
          // ListTile(
          //   leading: const Icon(Icons.language),
          //   title: const Text('Language'),
          //   subtitle: const Text('English'),
          //   onTap: () {
          //     // Handle language change
          //   },
          // ),
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
