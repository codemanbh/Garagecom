import './Comment.dart';

class Post {
  final int postID;
  final String title;
  final String description;
  String autherUsername; // Changed to non-final to allow setting username
  String? imageUrl;
  int numOfVotes;
  String? createdIn; // New field for created date
  String? categoryName; // New field for category name

  Post({
    required this.postID,
    required this.title,
    required this.description,
    required this.autherUsername,
    this.imageUrl,
    this.numOfVotes = 0,
    this.createdIn,
    this.categoryName,
  });

  void upVote() {
    numOfVotes++;
  }

  void downVote() {
    numOfVotes--;
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
