import 'package:flutter/material.dart';
import 'package:garagecom/utils/Validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'dart:convert';
import '../helpers/notificationHelper.dart';
import './../models/User.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false; // Add this line to track loading state

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  int? _extractUserIdFromToken(String token) {
    try {
      // JWT token consists of three parts separated by dots: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // The payload is the second part
      final payload = parts[1];

      // Payload is base64Url encoded - decode it
      String normalizedPayload = payload;
      // Add padding if needed
      while (normalizedPayload.length % 4 != 0) {
        normalizedPayload += '=';
      }

      // Convert the base64url to base64
      normalizedPayload =
          normalizedPayload.replaceAll('-', '+').replaceAll('_', '/');

      // Decode base64
      final decodedBytes = base64Decode(normalizedPayload);
      final decodedPayload = utf8.decode(decodedBytes);

      // Parse JSON
      final payloadJson = jsonDecode(decodedPayload);

      // Check various common field names for user ID
      if (payloadJson.containsKey('UserID')) {
        return payloadJson['UserID'];
      } else if (payloadJson.containsKey('UserId')) {
        return payloadJson['UserId'];
      } else if (payloadJson.containsKey('user_id')) {
        return payloadJson['user_id'];
      } else if (payloadJson.containsKey('sub')) {
        // Often 'sub' (subject) is the user identifier in JWTs
        // Try to parse it as int if possible
        final sub = payloadJson['sub'];
        if (sub is int) return sub;
        if (sub is String && int.tryParse(sub) != null) {
          return int.parse(sub);
        }
      }

      print('JWT payload does not contain recognizable user ID: $payloadJson');
      return null;
    } catch (e) {
      print('Error extracting user ID from token: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Added logo at the top
                Container(
                  height: 80,
                  width: 350,
                  margin: const EdgeInsets.only(top: 50, bottom: 20),
                  child: Image.asset(
                    'assets/logo-raw-purple.png',
                    height: 50,
                    width: 10,
                    fit: BoxFit.fitHeight,
                    errorBuilder: (context, error, stackTrace) {
                      print('Logo loading error: $error');
                      return Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                ),
                const Text(
                  'Welcome!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  'Log in or create an account to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: usernameController,
                  validator: Validators.username,
                  decoration: InputDecoration(
                    labelText: 'username',
                    prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  validator: Validators.password,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            // Form is valid, do something
                            return;
                          }
                          // Set loading state to true
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            print('login button pressed');
                            // String deviceToken = await notificationHelper.getNotiToken();

                            Map<String, dynamic> data = {
                              'userName': usernameController.text,
                              'password': passwordController.text,
                              // 'deviceToken': deviceToken
                            };

                            print("***********************" + data.toString());

                            Map<String, dynamic> response =
                                await ApiHelper.post(
                                    "api/Registration/login", data);
                            print(response);
                            print(response["succeeded"]);

                            // Reset loading state after getting response
                            setState(() {
                              _isLoading = false;
                            });

                            if (response["succeeded"] == true) {
                              String token = response["parameters"]["Token"];

                              // Safely handle missing UserID
                              int? userId;
                              if (response["parameters"]
                                      .containsKey("UserID") &&
                                  response["parameters"]["UserID"] != null) {
                                userId = response["parameters"]["UserID"];
                              } else if (response["parameters"]
                                      .containsKey("UserId") &&
                                  response["parameters"]["UserId"] != null) {
                                // Try alternate casing of UserId
                                userId = response["parameters"]["UserId"];
                              } else {
                                // Extract user ID from token if possible
                                userId = _extractUserIdFromToken(token);
                              }

                              // Store token and userId (if available)
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString("token", token);
                              User.token = token;

                              if (userId != null) {
                                await prefs.setInt("userId", userId);
                              }

                              // Navigate to home page
                              Navigator.of(context)
                                  .popAndPushNamed('/mainPage');
                            } else {
                              // Show more specific error message if available
                              String errorMessage = response["message"] ??
                                  'Login failed. Please check your credentials.';

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          } catch (e) {
                            // Reset loading state in case of error
                            setState(() {
                              _isLoading = false;
                            });

                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor:
                        colorScheme.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Navigate to the signup page
                    Navigator.of(context).popAndPushNamed('/signup');
                  },
                  child: Text(
                    'Create an account',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
