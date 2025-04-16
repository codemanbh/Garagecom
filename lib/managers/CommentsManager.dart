import '../models/Comment.dart';

class CommentsManager {
  List<Comment> comments = [];

  PostsManager() {
    fetchPosts();
  }

  Future<bool> fetchPosts() async {
    // Dio _dio = Dio();
    // final response = await _dio.get('http://192.168.243.1:3000/posts/1/comments');

    // print('asdasd');
    // if (response.statusCode == 200) {
    //   List<dynamic> posts = response.data['posts'];
    //   List<Comment> x = posts
    //       .map((x) => Comment(
    //         )
    //       .toList();

    //   Post.posts = x;
    // }

    return true;
  }
}
