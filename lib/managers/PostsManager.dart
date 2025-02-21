import 'package:dio/dio.dart';
import '../models/Post.dart';

class PostsManager {
  static List<Post> posts = [];
  Dio _dio = Dio();

  PostsManager() {
    fetchPosts();
  }

  Future<bool> fetchPostDetails(int post_id) async {
    final response =
        await _dio.get('http://192.168.243.1:3000/api/posts/${post_id}');
    if (response.statusCode == 200) {
      // Post post = Post();
    }

    return true;
  }

  Future<bool> fetchPosts() async {
    final response = await _dio.get('http://192.168.243.1:3000/posts');
    print('asdasd');
    if (response.statusCode == 200) {
      List<dynamic> posts = response.data['posts'];
      List<Post> x = posts
          .map((x) => Post(
              title: x['title'],
              numOfVotes: 0,
              imageUrl: 'https://example.com/image2.jpg'))
          .toList();

      posts = x;
    }

    return true;
  }
}
