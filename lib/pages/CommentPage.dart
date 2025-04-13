import 'package:flutter/material.dart';
import '../components/VoteButtons.dart';
import '../components/CommentCard.dart';

class CommentPage extends StatefulWidget {
  final String postTitle;
  final String questionBody;
  final int initialVotes;
  final String? imageUrl;

  const CommentPage({
    super.key,
    required this.postTitle,
    required this.questionBody,
    required this.initialVotes,
    this.imageUrl,
  });

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  int postVotes = 0;
  String? imageUrl = '';

  final List<Map<String, dynamic>> comments = [
    {'text': 'This is a very helpful question!', 'votes': 3},
    {'text': 'I have the same query as well.', 'votes': 1},
  ];
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    postVotes = widget.initialVotes;
    imageUrl = widget.imageUrl;
  }

  void upvotePost() {
    setState(() {
      postVotes++;
    });
  }

  void downvotePost() {
    setState(() {
      postVotes--;
    });
  }

  void upvoteComment(int index) {
    setState(() {
      comments[index]['votes']++;
    });
  }

  void downvoteComment(int index) {
    setState(() {
      comments[index]['votes']--;
    });
  }

  void addComment() {
    final newComment = commentController.text.trim();
    if (newComment.isNotEmpty) {
      setState(() {
        comments.add({'text': newComment, 'votes': 0});
        commentController.clear();
      });
    }
  }

  Widget PostHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        'imageUrl' != null
            ? Image.network(
                imageUrl ?? '',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              )
            : SizedBox(),
        const Padding(
          padding: const EdgeInsets.all(16.0),
          // child: Text('questionBody'),
        ),
        // Add other widgets for comments, etc.

        // Display the full question
        Text(
          widget.postTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. ",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            VoteButtons(),
          ],
        ),

        // Post votes
      ],
    );
  }

  Widget writeComment() {
    return TextField(
      minLines: 1,
      maxLines: 3,
      controller: commentController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 23),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.blue),
        ),
        hintText: 'Write a comment...',
        suffixIcon: IconButton(
          onPressed: addComment,
          icon: const Icon(Icons.send, color: Colors.blue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostHeader(),
              const Divider(height: 32),

              // Comments section
              const Text(
                'Comments:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return CommentCard();
                },
              ),

              const Divider(height: 32),

              // Add a new comment
              const Text(
                'Add a Comment:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              writeComment()
            ],
          ),
        ),
      ),
    );
  }
}
