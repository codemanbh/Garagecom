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
