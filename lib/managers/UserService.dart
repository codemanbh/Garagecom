import 'dart:io';
import '../helpers/apiHelper.dart';
import '../models/UserData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  // Get the authenticated user's profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await ApiHelper.get('api/Profile/GetUserDetails', {});

      if (response['succeeded'] == true &&
          response['parameters'] != null &&
          response['parameters']['User'] != null) {
        return response;
      } else {
        throw Exception(
            'Failed to load user profile: ${response['message'] ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  // Update the user's profile
  static Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> userData) async {
    try {
      final response =
          await ApiHelper.post('api/Profile/UpdateUserDetails', userData);

      if (response['succeeded'] == true) {
        return response;
      } else {
        throw Exception(
            'Failed to update profile: ${response['message'] ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  // Get the user's cars
  static Future<Map<String, dynamic>> getUserCars() async {
    try {
      final response = await ApiHelper.get('api/Cars/GetUserCars', {});

      if (response['succeeded'] == true && response['parameters'] != null) {
        return response;
      } else {
        throw Exception(
            'Failed to load user cars: ${response['message'] ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Error fetching user cars: $e');
    }
  }

  // Add a new car
  static Future<Map<String, dynamic>> addCar(
      Map<String, dynamic> carData) async {
    try {
      // Simplify the data structure to match what the API expects
      final simplifiedData = {
        'medelID': carData['model']['ModelID'],
        'year': carData['year'],
        'nickname': carData['nickname'] ?? '',
        'kilos': carData['kilos'] ?? 0,
      };

      // Log what we're sending for debugging
      print('Sending car data: $simplifiedData');

      final response = await ApiHelper.post('api/Cars/SetCar', simplifiedData);

      if (response['succeeded'] == true) {
        return response;
      } else {
        throw Exception(
            'Failed to add car: ${response['message'] ?? "Unknown error"}');
      }
    } catch (e) {
      print('Error details: $e');
      throw Exception('Error adding car: $e');
    }
  }

  // Update an existing car
  static Future<Map<String, dynamic>> updateCar(
      Map<String, dynamic> carData) async {
    try {
      final response = await ApiHelper.post('api/Cars/UpdateUserCar', carData);

      if (response['succeeded'] == true) {
        return response;
      } else {
        throw Exception(
            'Failed to update car: ${response['message'] ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Error updating car: $e');
    }
  }

  // Delete a car
  static Future<Map<String, dynamic>> deleteCar(int carId) async {
    try {
      final response =
          await ApiHelper.post('api/Cars/DeleteCar', {'carID': carId});

      if (response['succeeded'] == true) {
        return response;
      } else {
        throw Exception(
            'Failed to delete car: ${response['message'] ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Error deleting car: $e');
    }
  }

  // Get all car brands and models to extract unique brands
  static Future<Map<String, dynamic>> getCarBrands() async {
    try {
      final response = await ApiHelper.get('api/Cars/GetCarModels', {});

      if (response['succeeded'] == true &&
          response['parameters'] != null &&
          response['parameters']['CarModels'] != null) {
        // Get the CarModels array
        List<dynamic> carModels = response['parameters']['CarModels'];

        // Extract unique brands
        Set<int> brandIdSet = {};
        List<Map<String, dynamic>> uniqueBrands = [];

        for (var model in carModels) {
          if (model['brand'] != null) {
            int brandId = model['brand']['brandID'];
            if (!brandIdSet.contains(brandId)) {
              brandIdSet.add(brandId);
              uniqueBrands.add(model['brand']);
            }
          }
        }

        // Create a response similar to what the loadBrands method expects
        return {
          'succeeded': true,
          'parameters': {'Brands': uniqueBrands}
        };
      } else {
        throw Exception(
            'Failed to load car brands: ${response['message'] ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Error fetching car brands: $e');
    }
  }

  // Get models for a specific brand
  static Future<Map<String, dynamic>> getCarModels(int brandId) async {
    try {
      final response = await ApiHelper.get('api/Cars/GetCarModels', {});

      if (response['succeeded'] == true &&
          response['parameters'] != null &&
          response['parameters']['CarModels'] != null) {
        // Get all car models and filter by the selected brand ID
        List<dynamic> allModels = response['parameters']['CarModels'];
        List<dynamic> brandModels = allModels
            .where((model) =>
                model['brand'] != null && model['brand']['brandID'] == brandId)
            .toList();

        // Create a response similar to what the loadModels method expects
        return {
          'succeeded': true,
          'parameters': {'Models': brandModels}
        };
      } else {
        throw Exception(
            'Failed to load car models: ${response['message'] ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Error fetching car models: $e');
    }
  }

  // Upload profile picture
  static Future<Map<String, dynamic>> uploadProfilePicture(
      File imageFile) async {
    try {
      final response = await ApiHelper.uploadImage(
          imageFile, 'api/Users/UploadProfilePicture');

      if (response['succeeded'] == true) {
        return response;
      } else {
        throw Exception(
            'Failed to upload profile picture: ${response['message'] ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Error uploading profile picture: $e');
    }
  }
}
