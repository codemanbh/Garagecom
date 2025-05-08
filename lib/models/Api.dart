import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class Api {
  static final Dio _dio = Dio();
  static final CookieJar _cookieJar = CookieJar();

  Api() {
    // Add interceptors
    _dio.interceptors.add(CookieManager(_cookieJar));
    // _dio.interceptors
    //     .add(LogInterceptor(requestBody: true, responseBody: true));

    // Configure base options
    _dio.options = BaseOptions(
      baseUrl: 'http://10.0.2.2:3000', // Use this for Android emulator
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );
  }

  Future<void> testCookies() async {
    try {
      // First request to set cookie
      final response1 = await _dio.get('/set-cookie');
      print('First response: ${response1.data}');

      // Check cookies
      final cookies =
          await _cookieJar.loadForRequest(Uri.parse(_dio.options.baseUrl));
      print('Cookies: $cookies');

      // Second request to verify
      final response2 = await _dio.get('/check-cookie');
      print('Second response: ${response2.data}');
    } catch (e) {
      print('Error details:');
      if (e is DioException) {
        print(e.message);
        print(e.response?.statusCode);
        print(e.response?.data);
      } else {
        print(e.toString());
      }
    }
  }
}
