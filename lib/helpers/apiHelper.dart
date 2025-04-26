import 'dart:io';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper {
  late Dio dio;
  static String mainDomain = 'https://9bef-77-69-247-225.ngrok-free.app/';

  static Future<Dio> Client() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString('token');

    final dio = Dio(BaseOptions(
      baseUrl: mainDomain,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }, // Changed to JSON
      // headers: {'Content-Type': 'multipart/form-data'}, // Changed to JSON

      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      // Don't throw on error status codes - let us handle them
      validateStatus: (status) => true,
    ));

    print("token2: $token");

    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    // Add logging interceptor for debugging
    // //dio.interceptors.add(LogInterceptor(
    //   requestBody: true,
    //   responseBody: true,
    //   error: true,
    //   requestHeader: true,
    //   responseHeader: true,
    // ));

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    return dio;
  }

  static Future<Map<String, dynamic>> get(
      String path, Map<String, dynamic> data) async {
    try {
      Dio client = await Client();
      print('GET Request to: ${client.options.baseUrl}$path');
      print('Parameters: $data');

      final response = await client.get(
        path,
        queryParameters: data,
      );

      _handleResponse(response);
      return response.data;
    } catch (e) {
      print('GET Error: $e');
      return {'error': e.toString()};
    }
  }

  static Future<Image> _image(String imageName, String path) async {
    final prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString('token');
    String fullImageUrl = '$mainDomain$path/?filename=$imageName';
    print(fullImageUrl);
    Map<String, String> headers = {};
    if (token != null) {
      headers = {"Authorization": token};
    }
    return Image.network(
      fullImageUrl,
      headers: headers,
    );
  }

  static FutureBuilder<Image> image(String imageName, String path) {
    return FutureBuilder<Image>(
      future: ApiHelper._image(imageName, path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error);
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return const SizedBox(); // fallback
        }
      },
    );
  }

  static Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> data) async {
    try {
      Dio client = await Client();
      print('POST Request to: ${client.options.baseUrl}$path');
      print('Data: $data');

      // Try using data in body instead of queryParameters
      final response = await client.post(
        path,
        data: data, // Use data for POST body
      );

      _handleResponse(response);
      return response.data;
    } catch (e) {
      print('POST Error: $e');
      return {'error': e.toString()};
    }
  }

  // Helper to check response status and handle errors
  static void _handleResponse(Response response) {
    print('Response status code: ${response.statusCode}');

    if (response.statusCode == 500) {
      print('Server Error: ${response.data}');
      throw Exception('Server error: ${response.data.toString()}');
    }

    if (response.statusCode != 200) {
      print('Request failed with status: ${response.statusCode}');
      print('Response data: ${response.data}');
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  // Add a troubleshooting method
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      Dio dio = Dio();

      // Try connecting to a well-known service
      final response = await dio.get('https://www.google.com');
      return {
        'status': 'success',
        'message':
            'Internet connection is working, status code: ${response.statusCode}'
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Unable to connect to the internet: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> uploadImage(File image, String path,
      {Map<String, dynamic>? options}) async {
    options ??= {};
    Dio client = await Client();
    client.options.headers['Content-Type'] = 'multipart/form-data';

    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path,
          contentType: DioMediaType.parse("image/jpg"),
          filename: image.path.split('/').last),
      ...options
    });

    try {
      final response = await client.post(
        path,
        data: formData,
      );

      return response.data;
    } catch (e) {
      print('Image upload error: $e');
      return {'error': e.toString()};
    }
  }
}
