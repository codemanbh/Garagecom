import 'package:flutter/material.dart';

class VoteButtons extends StatefulWidget {
  const VoteButtons({super.key});

  @override
  State<VoteButtons> createState() => _VoteButtonsState();
}

class _VoteButtonsState extends State<VoteButtons> {
  Widget voteButton(String direction) {
    IconData i = direction == 'up' ? Icons.arrow_upward : Icons.arrow_downward;
    return IconButton.filled(
      onPressed: () {},
      icon: Icon(i, size: 18),
      color: Theme.of(context).scaffoldBackgroundColor,
      style: IconButton.styleFrom(
          backgroundColor: Colors.white, minimumSize: Size(18, 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        // color: Colors.blue,
        color: const Color.fromARGB(255, 157, 157, 157),
        borderRadius: BorderRadius.circular(200), // Half of the width/height
      ),
      child: Column(
        children: [
          voteButton('up'),
          Container(
            margin: EdgeInsets.symmetric(vertical: 3),
            child: const Text('0',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
          voteButton('down'),
        ],
      ),
    );
  }
}
