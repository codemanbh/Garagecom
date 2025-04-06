import 'package:flutter/material.dart';
import '../pages/CommentPage.dart';
import '../components/VoteButtons.dart';

class PostWidget extends StatelessWidget {
  final String accountId;
  final String accountName;
  final String postId;
  final String postTitle;
  final String postContent;
  final int numOfVotes;
  final VoidCallback upvote;
  final VoidCallback downvote;

  const PostWidget({
    Key? key,
    required this.accountId,
    required this.accountName,
    required this.postId,
    required this.postTitle,
    required this.postContent,
    required this.numOfVotes,
    required this.upvote,
    required this.downvote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String postAccount = 'AccourdMaster';
    String postTitle = "Car battery draining overnight";
    String postContent =
        "I keep waking up to a dead battery. What could be causing this?";

    return Container(
      padding: EdgeInsets.fromLTRB(10, 9, 10, 10),
      decoration: BoxDecoration(
        // color: Colors.blue,
        color: const Color.fromARGB(255, 109, 109, 109),

        borderRadius: BorderRadius.circular(12), // Half of the width/height
      ),
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentPage(
                      postTitle: 'asd', questionBody: 'asd', initialVotes: 0),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.white, radius: 10),
                    SizedBox(
                      width: 7,
                    ),
                    Text(postAccount),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(postTitle,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: 300,
                  child: Text(postContent,
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16)),
                )
              ],
            ),
          ),
          // votes
          VoteButtons()
        ],
      ),
    );
  }
}
