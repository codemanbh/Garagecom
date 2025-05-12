import './Comment.dart';
import './../helpers/apiHelper.dart';

class Post {
  final int postID;
  final String title;
  final String description;
  String autherUsername; // Changed to non-final to allow setting username
  String? imageUrl;
  int numOfVotes;
  String? createdIn; // New field for created date
  String? categoryName; // New field for category name
  int userVote = 0;
  int voteValue = 0;
  int autherId;
  bool allowComments;
  Post(
      {required this.postID,
      required this.title,
      required this.description,
      required this.autherUsername,
      this.autherId = -1,
      this.imageUrl,
      this.numOfVotes = 0,
      this.createdIn,
      this.categoryName,
      this.voteValue = 0,
      required this.allowComments});

  Future<void> handleUpvote() async {
    if (voteValue == 0 || voteValue == -1) {
      if (voteValue == -1) {
        await ApiHelper.post(
          'api/posts/DeleteVote',
          {'PostID': postID},
        );
      }

      await ApiHelper.post(
        'api/posts/SetVote',
        {'PostID': postID, 'value': 1},
      );
      voteValue = 1;
      numOfVotes++;
    } else if (voteValue == 1) {
      await ApiHelper.post(
        'api/posts/DeleteVote',
        {'PostID': postID},
      );
      voteValue = 0;
      numOfVotes--;
    }
  }

  Future<void> handleDownvote() async {
    print('--- downvote hit');
    print("voteValue: ${voteValue}");

    if (voteValue == 0 || voteValue == 1) {
      print("inside 1");
      if (voteValue == 1) {
        await ApiHelper.post(
          'api/posts/DeleteVote',
          {'PostID': postID},
        );
      }

      await ApiHelper.post(
        'api/posts/SetVote',
        {'PostID': postID, 'value': -1},
      );
      voteValue = -1;
      numOfVotes--;
    } else if (voteValue == -1) {
      print("inside 2");
      await ApiHelper.post(
        'api/posts/DeleteVote',
        {'PostID': postID},
      );
      numOfVotes++;
      voteValue = 0;
    }
  }

  // Format the date to a more readable format
  String getFormattedDate() {
    if (createdIn == null || createdIn!.isEmpty) {
      return "Unknown date";
    }

    try {
      // Parse the date from the format "2025-04-24 22:34:20"
      DateTime dateTime = DateTime.parse(createdIn!);

      // Get difference from now
      final difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 365) {
        return "${(difference.inDays / 365).floor()} years ago";
      } else if (difference.inDays > 30) {
        return "${(difference.inDays / 30).floor()} months ago";
      } else if (difference.inDays > 0) {
        return "${difference.inDays} days ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours} hours ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes} minutes ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return createdIn ?? "Unknown date";
    }
  }
}
