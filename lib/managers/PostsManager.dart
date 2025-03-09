import 'package:dio/dio.dart';
import '../models/Post.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import './posts.dart';

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
    // final response = await _dio.get('http://192.168.243.1:3000/api/posts');
    // print('asdasd');
    // if (response.statusCode == 200) {
    //   List<dynamic> posts = response.data['posts'];
    //   List<Post> x = posts
    //       .map((x) => Post(
    //           title: x['title'],
    //           numOfVotes: 0,
    //           imageUrl: 'https://example.com/image2.jpg'))
    //       .toList();

    //   posts = x;
    // }

    // Load the JSON file from the assets
    // final String jsonString =
    // await rootBundle.loadString('assets/data/posts.json');
    // Decode the JSON data
    // List<dynamic> p = json.decode(jsonString)['posts'];
    // print(posts);
    List<dynamic> x = posts_map['posts']
        .map((x) => Post(
            title: x['title'],
            numOfVotes: 0,
            imageUrl: x['image'],
            description: x['content']))
        .toList();

    posts = x as List<Post>;

    return true;
  }
}
