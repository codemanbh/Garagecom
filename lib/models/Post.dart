import './Comment.dart';

class Post {
  int postID;
  String title = '';
  String description = '';
  List<String> images = [];
  List<Comment> comments = [];
  int numOfVotes = 0;
  bool isVoted = false;
  String autherUsername = '';
  int autherID = 0;
  String imageUrl = '';
  int accountId = 0;

  Post(
      {required this.postID,
      required this.title,
      required this.autherUsername,
      required this.numOfVotes,
      this.imageUrl = '',
      this.description = '',
      this.accountId = 0});

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
