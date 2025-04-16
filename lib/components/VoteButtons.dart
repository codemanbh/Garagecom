import 'package:flutter/material.dart';

class VoteButtons extends StatefulWidget {
  final String size;
  const VoteButtons({super.key, this.size = 'large'});

  @override
  State<VoteButtons> createState() => _VoteButtonsState();
}

class _VoteButtonsState extends State<VoteButtons> {
  Widget voteButton(String direction) {
    IconData i = direction == 'up' ? Icons.arrow_upward : Icons.arrow_downward;
    return IconButton.filled(
      onPressed: () {},
      icon: Icon(i, size: widget.size == 'large' ? 18 : 13),
      color: Theme.of(context).scaffoldBackgroundColor,
      style: IconButton.styleFrom(
          backgroundColor: Colors.white, minimumSize: const Size(18, 18)),
    );
  }

  double lineHeight() {
    return widget.size == 'large' ? 2 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        // color: Colors.blue,
        color: widget.size == 'large'
            ? const Color.fromARGB(255, 157, 157, 157)
            : const Color.fromARGB(0, 157, 157, 157),
        borderRadius: BorderRadius.circular(200), // Half of the width/height
      ),
      child: Column(
        children: [
          voteButton('up'),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: Text('0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: lineHeight(),
                )),
          ),
          voteButton('down'),
        ],
      ),
    );
  }
}
