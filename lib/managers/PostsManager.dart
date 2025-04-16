import 'package:dio/dio.dart';
import '../models/Post.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/posts.dart';

class PostsManager {
  static List<Post> posts = [];
  final Dio _dio = Dio();

  PostsManager() {
    fetchPosts();
  }

  Future<bool> fetchPostDetails(int postId) async {
    final response =
        await _dio.get('http://192.168.243.1:3000/api/posts/$postId');
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

    List<Map<String, dynamic>> postsMap = [
      {
        "id": 1,
        "autherUsername": "GlitchHorizon",
        "title": "I have a weird sound in my Accord car engine",
        "content":
            "I've been hearing a strange ticking noise coming from my engine. Has anyone experienced this before?",
        "image": "https://example.com/images/accord-engine.jpg"
      },
      {
        "id": 2,
        "autherUsername": "TurboAccord2.0",
        "title": "Best tires for off-road driving?",
        "content":
            "I'm looking for durable off-road tires for my Jeep Wrangler. Any recommendations?",
        "image": "https://example.com/images/jeep-tires.jpg"
      },
      {
        "id": 3,
        "autherUsername": "BoostedDaily",
        "title": "Check engine light keeps turning on!",
        "content":
            "My check engine light keeps coming on and off. What could be the issue?",
        "image": "https://example.com/images/check-engine.jpg"
      },
      {
        "id": 4,
        "autherUsername": "TurboAccord2.0",
        "title": "Upgrading my exhaust system!",
        "content":
            "Thinking of installing a performance exhaust on my Mustang. Any suggestions?",
        "image": "https://example.com/images/mustang-exhaust.jpg"
      },
      {
        "id": 5,
        "autherUsername": "VTECUnleashed",
        "title": "Strange smell from the AC",
        "content":
            "Whenever I turn on my AC, there’s a moldy smell. How can I fix this?",
        "image": "https://example.com/images/car-ac.jpg"
      },
      {
        "id": 6,
        "autherUsername": "SportModeKing",
        "title": "Is ceramic coating worth it?",
        "content":
            "Thinking of getting ceramic coating for my car. Does it really help protect the paint?",
        "image": "https://example.com/images/ceramic-coating.jpg"
      },
      {
        "id": 7,
        "autherUsername": "VTECUnleashed",
        "title": "Best budget-friendly dash cams?",
        "content":
            "Looking for a reliable but affordable dash cam. Any recommendations?",
        "image": "https://example.com/images/dash-cam.jpg"
      },
      {
        "id": 8,
        "autherUsername": "GlitchHorizon",
        "title": "Car battery draining overnight",
        "content":
            "I keep waking up to a dead battery. What could be causing this?",
        "image": "https://example.com/images/car-battery.jpg"
      },
      {
        "id": 9,
        "autherUsername": "EcoModeRider",
        "title": "DIY oil change guide",
        "content":
            "Just changed my own oil for the first time! Here's a step-by-step guide.",
        "image": "https://example.com/images/oil-change.jpg"
      },
      {
        "id": 10,
        "autherUsername": "BoostedDaily",
        "title": "Loud squeaking when braking",
        "content":
            "My brakes make a loud squeaking noise when I stop. Should I replace the pads?",
        "image": "https://example.com/images/brake-noise.jpg"
      }
    ];

    List<dynamic> x = postsMap
        .map((x) => Post(
            postID: x['id'],
            title: x['title'],
            numOfVotes: 0,
            autherUsername: x['autherUsername'],
            imageUrl: x['image'],
            description: x['content']))
        .toList();

    posts = x as List<Post>;

    return true;
  }
}
