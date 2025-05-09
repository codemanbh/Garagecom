import 'package:flutter/material.dart';
import 'package:garagecom/pages/CommentPage.dart';
import '../helpers/apiHelper.dart';
import '../models/Post.dart';

class PostSearchDelegate extends SearchDelegate<Post?> {
  List<Post> posts = [];

  PostSearchDelegate();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clears the search query
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context,
            null); // Closes the search delegate without returning a result
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _sendApi(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading suggestions: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No suggestions found'));
        }

        List<Post> suggestionList = snapshot.data!;

        return _buildSuggestionList(suggestionList);
      },
    );


  }

  Future<List<Post>> _sendApi(String query) async {
    Map<String, dynamic> response = await ApiHelper.get(
      'api/Posts/SearchPosts',
      {'searchText': query},
    );
    if (response['succeeded'] == true) {
      var postsData = response['parameters']['Posts'];
      posts.clear();
      for(var postData in postsData) {
        Post post = Post(
          postID: postData['postID'] ?? 0,
          title: postData['title'] ?? 'No Title',
          description: postData['description'] ?? 'No Content',
          autherUsername: postData['userName'] ?? "",
          imageUrl: postData['attachment'] != null && postData['attachment'].isNotEmpty
              ? postData['attachment']
              : null,
          numOfVotes: postData['countVotes'] != null ? postData['countVotes'] : 0,
          voteValue: postData['voteValue'] != null ? postData['voteValue'] : 0,
          createdIn: postData['createdIn'] ?? '',
          categoryName: postData['postCategory'] != null
              ? postData['postCategory']['title']
              : '',
          allowComments: postData['allowComments'] ?? true
        );
        posts.add(post);
      }
      return posts;
    } else {
      return [];
    }
  }

  Widget _buildSuggestionList(List<Post> suggestionList) {
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        Post post = suggestionList[index];
        return ListTile(
          title: Text(post.title),
          subtitle: Text(post.description),
          onTap: () {
            close(context, post);
            print("Post ID (SEARCH DELEGATE): ${post.postID}");
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommentPage(postId: post.postID)));
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _sendApi(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading suggestions'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No suggestions found'));
        }

        List<Post> suggestionList = snapshot.data!;

        return _buildSuggestionList(suggestionList);
      },
    );
  }
}
