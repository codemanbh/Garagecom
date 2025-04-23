import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';


class  ApiHelper {
  late Dio dio;
  static String mainDomain = 'http://10.0.2.2:7035/';

  static Future<Dio> Client() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final dio = Dio(BaseOptions(
      baseUrl: mainDomain,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    ));

    if(token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    (dio.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    return dio;
  }


  static Future<Map<String, dynamic>> get(
      String path, Map<String, dynamic> data) async {
    Dio client = await Client();

    final response = await client.get(
      path,
      queryParameters: data,
    );

    return response.data;
  }
  static Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> data) async {
    Dio client = await Client();
    print(data);
    print(path);
    print(client);
    print(client.options.headers);
    final response = await client.post(
      path,
      queryParameters: data,
    );
    print(response);
    return response.data;
  }
}
