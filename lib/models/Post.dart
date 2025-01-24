import './Comment.dart';

class Post {
  String title = '';
  String description = '';
  List<String> images = [];
  List<Comment> comments = [];
  int numOfVotes = 0;
  bool isVoted = false;
  String autherUsername = '';
  int autherID = 0;

  Post({required this.title, required this.numOfVotes});

  static List<Post> posts = [
    Post(
        title: "Toyota Corolla 2020: Why won't my car start suddenly?",
        numOfVotes: 4),
    Post(
        title: "Honda Civic 2018: How to fix overheating engine issue?",
        numOfVotes: 3),
    Post(
        title: "Ford Mustang 2021: Why is my brake pedal stiff?",
        numOfVotes: 6),
  ];

  bool upVote() {
    numOfVotes++;
    // handel serverside logic

    return true;
  }

  bool downVote() {
    numOfVotes--;
    // handel serverside logic

    return true;
  }

  bool deletePost() {
    throw "not emplemented";
    return true;
  }

  bool createPost() {
    throw "not emplemented";
    return true;
  }
}
