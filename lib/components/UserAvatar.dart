import 'package:flutter/material.dart';
import '../helpers/apiHelper.dart';

class UserAvatar extends StatefulWidget {
  final int autherId;
  final String autherUsername;
  final bool isComment;
  UserAvatar(
      {Key? key,
      required this.autherId,
      required this.autherUsername,
      this.isComment = false})
      : super(key: key);

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CircleAvatar(
      radius: widget.isComment ? 17 : 20,
      backgroundColor: colorScheme.primaryContainer,
      child: ClipOval(
        child: ApiHelper.image(
          '',
          'api/posts/GetUserAvatarByUserId',
          options: {
            "userId": widget.autherId,
          },
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            return Text(widget.autherUsername[0].toUpperCase());
          },
        ),
      ),
    );
  }
}
