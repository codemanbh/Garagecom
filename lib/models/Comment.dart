class Comment {
  final int commentID;
  final int userID;
  final int postID;
  final int parentID; // -1 for top-level comments
  final String text;
  final String createdIn;
  final String modifiedIn;
  
  // For voting functionality
  int upvotes = 0;
  int downvotes = 0;
  
  Comment({
    required this.commentID,
    required this.userID,
    required this.postID,
    required this.parentID,
    required this.text,
    required this.createdIn,
    this.modifiedIn = '',
    this.upvotes = 0,
    this.downvotes = 0,
  });
  
  // Format the date to a more readable format
  String getFormattedDate() {
    if (createdIn.isEmpty) {
      return "Unknown date";
    }
    
    try {
      // Parse the date from the format "2025-04-25 01:44:14"
      DateTime dateTime = DateTime.parse(createdIn);
      
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
      return createdIn;
    }
  }
  
  // Get username for display
  String getUsernameDisplay() {
    return "User #$userID"; // You can replace this with actual username lookup if available
  }
}
