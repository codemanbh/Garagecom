import 'package:flutter/material.dart';
import '../models/Post.dart';

class PostSearchDelegate extends SearchDelegate<Post?> {
  final List<Post> posts;

  PostSearchDelegate(this.posts);

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
    List<Post> suggestionList = query.isEmpty
        ? []
        : posts
            .where((post) =>
                post.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        Post post = suggestionList[index];
        return ListTile(
          title: Text(post.title),
          subtitle: Text(post.description),
          onTap: () {
            query = post.title;
            showResults(context); // Shows results for the selected suggestion
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Post> resultList = posts
        .where((post) => post.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: resultList.length,
      itemBuilder: (context, index) {
        Post post = resultList[index];
        return ListTile(
          title: Text(post.title),
          subtitle: Text(post.description),
          onTap: () {
            close(context, post); // Returns the selected post
          },
        );
      },
    );
  }
}
