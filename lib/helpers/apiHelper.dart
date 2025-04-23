import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class  ApiHelper {
  late Dio dio;
  static String mainDomain = 'https://localhost:5294';

  static Future<Dio> Client() async {
    Dio client = Dio();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    client.options = BaseOptions(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      // You can set other defaults here too, like:
      baseUrl: mainDomain,
    );

    return client;
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

    final response = await client.post(
      path,
      queryParameters: data,
    );

    return response.data;
  }
}
