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
  String imageUrl = '';

  Post({required this.title, required this.numOfVotes, this.imageUrl = ''});

  static List<Post> posts = [
    Post(
        title: "Toyota Corolla 2020: Why won't my car start suddenly?",
        numOfVotes: 4,
        imageUrl: 'https://example.com/image1.jpg'),
    Post(
        title: "Honda Civic 2018: How to fix overheating engine issue?",
        numOfVotes: 3,
        imageUrl: 'https://example.com/image2.jpg'),
    Post(
        title: "Ford Mustang 2: Why is my brake pedal stiff?",
        numOfVotes: 6,
        imageUrl: 'https://example.com/image3.jpg'),
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
