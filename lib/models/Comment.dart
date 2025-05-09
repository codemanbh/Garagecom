class Comment {
  final int commentID;
  final int userID;
  final int postID;
  final int parentID;
  final String text;
  final String createdIn;
  final String modifiedIn;
  final String username;
  final int upvotes;
  final int downvotes;

  Comment({
    required this.commentID,
    required this.userID,
    required this.postID,
    required this.parentID,
    required this.text,
    required this.createdIn,
    required this.modifiedIn,
    this.username =
        'Anonymous', // Default to 'Anonymous' if no username provided
    this.upvotes = 0,
    this.downvotes = 0,
  });

  String getFormattedDate() {
    return createdIn.isNotEmpty ? createdIn : 'Unknown date';
  }
}
