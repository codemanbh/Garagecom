import 'package:dio/dio.dart';
import 'package:garagecom/models/Category.dart';
import '../models/Post.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/posts.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    try {
      // Fetch posts from API
      Map<String, dynamic> response =
          await ApiHelper.get('api/Posts/GetPosts', {'categoryId': 1});

      print('API Response received');
      print(response);

      // Check if the API call was successful
      if (response.containsKey('succeeded') && response['succeeded'] == true) {
        print('API call successful');

        // Check if we have the Posts array in the parameters
        if (response.containsKey('parameters') &&
            response['parameters'] != null &&
            response['parameters'].containsKey('Posts')) {
          List<dynamic> postsData = response['parameters']['Posts'];
          print('Found ${postsData.length} posts in API response');

          // Clear existing posts
          posts.clear();

          // Map API data to Post objects
          for (var postData in postsData) {
            Post post = Post(
              postID: postData['postID'] ?? 0,
              title: postData['title'] ?? 'No Title',
              description: postData['description'] ?? 'No Content',
              autherUsername:
                  postData['userName'], // Using userID as placeholder
              imageUrl: postData['attachment'] != null &&
                      postData['attachment'].isNotEmpty
                  ? postData['attachment']
                  : null,
              numOfVotes:
                  postData['countVotes'] != null ? postData['countVotes'] : 0,
              voteValue:
                  postData['voteValue'] != null ? postData['voteValue'] : 0,
              createdIn: postData['createdIn'] ?? '',
              categoryName: postData['postCategory'] != null
                  ? postData['postCategory']['title']
                  : '',
            );

            posts.add(post);
          }

          print('Successfully parsed ${posts.length} posts from API');
          return true;
        } else {
          print('No Posts array found in parameters');
        }
      } else {
        // API call failed or returned an error
        String errorMessage = response['message'] ?? 'Unknown error';
        print('API call failed: $errorMessage');
      }

      // If we get here, something went wrong with the API response
      // Fall back to local data
      return _loadFallbackPosts();
    } catch (e) {
      print('Error fetching posts: $e');
      return _loadFallbackPosts();
    }
  }

  // Helper method to load fallback posts
  Future<bool> _loadFallbackPosts() async {
    print('Loading fallback posts...');

    List<Map<String, dynamic>> postsMap = [
      {
        "id": 1,
        "autherUsername": "GlitchHorizon",
        "title": "I have a weird sound in my Accord car engine",
        "content":
            "I've been hearing a strange ticking noise coming from my engine. Has anyone experienced this before?",
      },
      {
        "id": 2,
        "autherUsername": "TurboAccord2.0",
        "title": "Best tires for off-road driving?",
        "content":
            "I'm looking for durable off-road tires for my Jeep Wrangler. Any recommendations?",
        "image": "https://example.com/images/jeep-tires.jpg"
      },
      // Rest of your fallback posts...
    ];

    // Clear existing posts
    posts.clear();

    // Create new post objects from the map data
    for (var postMap in postsMap) {
      Post post = Post(
        postID: postMap['id'],
        title: postMap['title'],
        numOfVotes: 0,
        autherUsername: postMap['autherUsername'],
        imageUrl: postMap.containsKey('image') ? postMap['image'] : null,
        description: postMap['content'],
      );
      posts.add(post);
    }

    print('Loaded ${posts.length} fallback posts');
    return true;
  }
}
