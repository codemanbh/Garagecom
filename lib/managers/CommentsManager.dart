import 'dart:convert';
import '../models/Comment.dart';
import '../helpers/apiHelper.dart';

class CommentsManager {
  static List<Comment> comments = [];
  
  // Fetch comments for a specific post
  static Future<bool> fetchComments(int postId) async {
    try {
      // Call the API to get comments
      Map<String, dynamic> response = await ApiHelper.get(
        'api/Posts/GetCommentsByPostId', 
        {'postId': postId}
      );
      
      print('API Comments Response received for post $postId');
      
      // Check if the API call was successful
      if (response.containsKey('succeeded') && response['succeeded'] == true) {
        print('API comments call successful');
        
        // Check if we have the Comments array in the parameters
        if (response.containsKey('parameters') && 
            response['parameters'] != null &&
            response['parameters'].containsKey('Comments')) {
          
          List<dynamic> commentsData = response['parameters']['Comments'];
          print('Found ${commentsData.length} comments in API response');
          
          // Clear existing comments
          comments.clear();
          
          // Map API data to Comment objects
          for (var commentData in commentsData) {
            // Try multiple possible field names for username
            String username = commentData['username'] ?? 
                             commentData['userName'] ?? 
                             commentData['user_name'] ?? 
                             commentData['name'] ?? 
                             'Anonymous';

            Comment comment = Comment(
              commentID: commentData['commentID'] ?? 0,
              userID: commentData['userID'] ?? 0,
              postID: commentData['postID'] ?? 0,
              parentID: commentData['parentID'] ?? -1,
              text: commentData['text'] ?? '',
              createdIn: commentData['createdIn'] ?? '',
              modifiedIn: commentData['modifiedIn'] ?? '',
              username: username,
            );
            
            comments.add(comment);
          }
          
          print('Successfully parsed ${comments.length} comments from API');
          return true;
        } else {
          print('No Comments array found in parameters');
          comments.clear();
          return true; // Return true but with empty comments
        }
      } else {
        // API call failed or returned an error
        String errorMessage = response['message'] ?? 'Unknown error';
        print('API comments call failed: $errorMessage');
        return false;
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return false;
    }
  }
  
  // Add a new comment to a post
  static Future<bool> addComment(int postId, String text) async {
    try {
      // Prepare comment data for API
      Map<String, dynamic> commentData = {
        'postId': postId,
        'text': text,
      };
      
      print('Sending comment to API: $commentData');
      
      // Call API to add comment
      Map<String, dynamic> response = await ApiHelper.post(
        'api/Posts/SetComment', 
        commentData
      );
      
      print('Add comment response: $response');
      
      if (response.containsKey('succeeded') && response['succeeded'] == true) {
        print('Comment added successfully');
        // Refresh comments list
        return await fetchComments(postId);
      } else {
        print('Failed to add comment: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }
}
