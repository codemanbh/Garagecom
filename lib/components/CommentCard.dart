import 'package:flutter/material.dart';

class CommentCard extends StatefulWidget {
  final String username;
  final String content;
  final String timeAgo;
  final int upvotes;
  final int downvotes;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onReply;

  const CommentCard({
    super.key,
    required this.username,
    required this.content,
    required this.timeAgo,
    required this.upvotes,
    required this.downvotes,
    required this.onUpvote,
    required this.onDownvote,
    required this.onReply,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: colorScheme.surface,
      shadowColor: colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment header with user info
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    widget.username.isNotEmpty
                        ? widget.username[0].toUpperCase()
                        : "?",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${widget.username}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      widget.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (widget.upvotes - widget.downvotes) > 0
                        ? colorScheme.primary.withOpacity(0.1)
                        : (widget.upvotes - widget.downvotes) < 0
                            ? colorScheme.error.withOpacity(0.1)
                            : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.upvotes - widget.downvotes}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: (widget.upvotes - widget.downvotes) > 0
                          ? colorScheme.primary
                          : (widget.upvotes - widget.downvotes) < 0
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            // Comment content
            const SizedBox(height: 8),
            Text(
              widget.content,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
            ),

            // Comment actions
            const SizedBox(height: 8),

            // Row(
            //   children: [

            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         // Upvote button
            //         IconButton(
            //           onPressed: widget.onUpvote,
            //           icon: Icon(
            //             Icons.arrow_upward_rounded,
            //             size: 20,
            //             color: colorScheme.primary,
            //           ),
            //           style: IconButton.styleFrom(
            //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //             minimumSize: const Size(36, 36),
            //             padding: EdgeInsets.zero,
            //           ),
            //           tooltip: 'Upvote',
            //         ),
            //         // Combined vote count
            //         Container(
            //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //           decoration: BoxDecoration(
            //             color: (widget.upvotes - widget.downvotes) > 0
            //               ? colorScheme.primary.withOpacity(0.1)
            //               : (widget.upvotes - widget.downvotes) < 0
            //                 ? colorScheme.error.withOpacity(0.1)
            //                 : colorScheme.surfaceVariant,
            //             borderRadius: BorderRadius.circular(12),
            //             border: Border.all(
            //               color: (widget.upvotes - widget.downvotes) > 0
            //                 ? colorScheme.primary.withOpacity(0.5)
            //                 : (widget.upvotes - widget.downvotes) < 0
            //                   ? colorScheme.error.withOpacity(0.5)
            //                   : colorScheme.outline.withOpacity(0.3),
            //               width: 1,
            //             ),
            //           ),
            //           child: Text(
            //             '${widget.upvotes - widget.downvotes}',
            //             style: TextStyle(
            //               fontSize: 14,
            //               fontWeight: FontWeight.bold,
            //               color: (widget.upvotes - widget.downvotes) > 0
            //                 ? colorScheme.primary
            //                 : (widget.upvotes - widget.downvotes) < 0
            //                   ? colorScheme.error
            //                   : colorScheme.onSurfaceVariant,
            //             ),
            //           ),
            //         ),
            //         // Downvote button
            //         IconButton(
            //           onPressed: widget.onDownvote,
            //           icon: Icon(
            //             Icons.arrow_downward_rounded,
            //             size: 20,
            //             color: colorScheme.error,
            //           ),
            //           style: IconButton.styleFrom(
            //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //             minimumSize: const Size(36, 36),
            //             padding: EdgeInsets.zero,
            //           ),
            //           tooltip: 'Downvote',
            //         ),
            //       ],
            //     ),
            //     const Spacer(),
            //     TextButton.icon(
            //       onPressed: widget.onReply,
            //       icon: Icon(
            //         Icons.reply,
            //         size: 16,
            //         color: colorScheme.secondary,
            //       ),
            //       label: Text(
            //         'Reply',
            //         style: TextStyle(
            //           fontSize: 14,
            //           color: colorScheme.secondary,
            //         ),
            //       ),
            //       style: TextButton.styleFrom(
            //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //         minimumSize: Size.zero,
            //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
