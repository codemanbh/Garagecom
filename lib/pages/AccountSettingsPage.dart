import 'package:flutter/material.dart';
import '../components/CustomNavBar.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Add logic to save changes
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
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/images/avatar.png'), // Add your default avatar image
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () {
                    // Add logic to change avatar
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Full Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Email
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Phone Number
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Bio
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                prefixIcon: Icon(Icons.info),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Password
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Confirm Password
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
             const SizedBox(height: 20),
            // Car name
             TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Car name ',
                prefixIcon: Icon(Icons.car_repair),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
             TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Car model ',
                prefixIcon: Icon(Icons.car_repair_sharp),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
             TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'mailage  ',
                prefixIcon: Icon(Icons.car_repair_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            
            // Save Button
            
            ElevatedButton(
              onPressed: () {
                // Add logic to save changes
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.blue, // Custom button color
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}