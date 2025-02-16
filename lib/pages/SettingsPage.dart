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
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
                'https://th.bing.com/th/id/OIP.QsTQiIXafX4lsEPvCmognAHaHS?rs=1&pid=ImgDetMain'), // Replace with a real image URL
          ),
          const SizedBox(height: 16),
          Text(
            'Username: johndoe123',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Name: John Doe',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Email: johndoe@example.com',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Honda Accord 2022',
            style: TextStyle(fontSize: 16),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
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
