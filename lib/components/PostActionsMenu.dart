import 'package:flutter/material.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/ConfirmationHelper.dart';

class PostActionsMenu extends StatefulWidget {
  final int autherId;
  final bool isPost;
  final bool isComment;
  final int itemId;
  final bool isAdminView;
  PostActionsMenu(
      {Key? key,
      required this.autherId,
      required this.itemId,
      this.isPost = false,
      this.isComment = false,
      this.isAdminView = false})
      : super(key: key);

  @override
  State<PostActionsMenu> createState() => _PostActionsMenuState();
}

class _PostActionsMenuState extends State<PostActionsMenu> {
  int userId = -1;
  bool isAdminView = false;

  @override
  void initState() {
    super.initState();
    fetchUserID();
    isAdminView = widget.isAdminView;
  }

  fetchUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = await prefs.getInt('userId') ?? 0;
    setState(() {});
  }

  _handelReport() {
    ApiHelper.post('api/Posts/SetReport', {
      "itemID": widget.itemId,
      "isComment": widget.isComment,
      "isPost": widget.isPost
    });
    // conferm the close
  }

  _handelClose() {
    ApiHelper.post('api/Posts/ClosePost', {'postId': widget.itemId});
    // conferm
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isComment && userId == widget.autherId) {
      return SizedBox();
    }
    return PopupMenuButton<String>(
      onSelected: (value) {
        // Handle action selection
        if (value == 'close') {
          // Do edit
          _handelClose();
        } else if (value == 'report') {
          _handelReport();
        }
      },
      itemBuilder: (BuildContext context) => [
        userId == widget.autherId
            ? PopupMenuItem<String>(
                value: 'close',
                child: Text('Close'),
              )
            : PopupMenuItem<String>(
                value: 'report',
                child: Text('Report'),
              ),
      ],
      
      icon: 
      !isAdminView?
      Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 20,
      ) : const SizedBox.shrink(),
    );
  }
}
