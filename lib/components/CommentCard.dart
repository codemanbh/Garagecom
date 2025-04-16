import 'package:flutter/material.dart';
import '../components/VoteButtons.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({super.key});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String username = 'accord master';
  String content = "I don't know, maybe you should take your car to the garage";
  String wasPostedBefore = '2 days ago';

  TextStyle usernameStyle = const TextStyle(fontSize: 16);
  TextStyle contentStyle = const TextStyle(fontSize: 16);
  TextStyle wasPostedBeforeStyle =
      const TextStyle(fontSize: 16, color: Color.fromARGB(201, 255, 255, 255));

  SizedBox smallSpace = const SizedBox(
    height: 7,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // crossAxisAlignment: CrossAxisAlignment.st,
        children: [
          // left
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$username',
                  style: usernameStyle,
                ),
                smallSpace,
                Text(
                  content,
                  style: contentStyle,
                ),
                smallSpace,
                Text(
                  wasPostedBefore,
                  style: wasPostedBeforeStyle,
                ),
              ],
            ),
          ),
          // right
          const VoteButtons(size: 'small'),
        ],
      ),
    );
  }
}
