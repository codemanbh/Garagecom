import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class Api {
  f(String url) async {
    final dio = Dio();
    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    await dio.get('url');
    // Print cookies
    print(cookieJar.loadForRequest(Uri.parse('https://baidu.com/')));
    // second request with the cookie
    await dio.get('url');
  }
}
