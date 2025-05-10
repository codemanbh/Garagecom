import 'package:flutter/material.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'package:garagecom/helpers/notificationHelper.dart';
import 'package:garagecom/utils/Validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Join Garagecom and start managing your car maintenance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  controller: firstnameController,
                  validator: Validators.name,
                  decoration: InputDecoration(
                    labelText: 'First Name',
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
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: lastnameController,
                  validator: Validators.name,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
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
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  validator: Validators.email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: colorScheme.primary),
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
                  controller: usernameController,
                  validator: Validators.username,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon:
                        Icon(Icons.person_outline, color: colorScheme.primary),
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
                  controller: phoneController,
                  validator: Validators.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone, color: colorScheme.primary),
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmPasswordController,
                  validator: (value) {
                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      return "The confirm passwords don't match";
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon:
                        Icon(Icons.lock_outline, color: colorScheme.primary),
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
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            if (firstnameController.text.isEmpty ||
                                lastnameController.text.isEmpty ||
                                emailController.text.isEmpty ||
                                usernameController.text.isEmpty ||
                                passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please fill in all required fields')),
                              );
                              setState(() {
                                _isLoading = false;
                              });
                              return;
                            }

                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Passwords do not match')),
                              );
                              setState(() {
                                _isLoading = false;
                              });
                              return;
                            }

                            Map<String, dynamic> data = {
                              'firstName': firstnameController.text,
                              'lastName': lastnameController.text,
                              'email': emailController.text,
                              'userName': usernameController.text,
                              'phoneNumber': phoneController.text,
                              'password': passwordController.text,
                            };

                            Map<String, dynamic> response =
                                await ApiHelper.post(
                                    "api/Registration/register", data);

                            setState(() {
                              _isLoading = false;
                            });

                            if (response["succeeded"] as bool == true) {
                              String token = response["parameters"]["Token"];
                              int userId = response["parameters"]["UserID"];
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString("token", token);
                              await prefs.setInt("userId", userId);

                              Navigator.of(context)
                                  .popAndPushNamed('/mainPage');
                            } else {
                              String errorMessage = response["message"] ??
                                  'There was an error with registration';

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error during registration: ${e.toString()}'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
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
                          'Sign Up',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).popAndPushNamed('/loginPage');
                      },
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
