import 'package:flutter/material.dart';
import 'package:rakhsa/core/constants/colors.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/widgets/avatar.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final bool isRead;
  final bool isSingleAdmin;
  final String username;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
    required this.isSingleAdmin,
    required this.isRead,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final placeholderUrl =
        "https://i.pinimg.com/736x/d2/98/4e/d2984ec4b65a8568eab3dc2b640fc58e.jpg";

    final isAthan = username == "Athan";

    final currentTime = (DateTime.tryParse(time) ?? DateTime.now()).format(
      "HH:mm",
    );

    return Align(
      alignment: isMe ? .centerRight : .centerLeft,
      child: Column(
        spacing: 6,
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          if (!isMe && !isSingleAdmin)
            Row(
              spacing: 6,
              mainAxisSize: .min,
              children: [
                Avatar(
                  src: placeholderUrl,
                  initial: username,
                  radius: 12,
                  withBorder: true,
                  borderColor: isAthan ? primaryColor : Colors.grey,
                ),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.black54,
                    fontWeight: isAthan ? .w600 : .w500,
                  ),
                ),
              ],
            ),
          Container(
            padding: const .symmetric(vertical: 10.0, horizontal: 14.0),
            margin: .only(bottom: 12),
            constraints: BoxConstraints(maxWidth: context.getScreenHeight(0.7)),
            decoration: BoxDecoration(
              color: isMe ? primaryColor : Colors.grey.shade200,
              borderRadius: .only(
                topLeft: .circular(isMe ? 12 : 0),
                topRight: .circular(isMe ? 0 : 12),
                bottomLeft: .circular(12),
                bottomRight: .circular(12),
              ),
              border: !isMe
                  ? .all(color: isAthan ? primaryColor : Colors.grey)
                  : null,
            ),
            child: Column(
              spacing: 4,
              crossAxisAlignment: .end,
              mainAxisSize: .min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),

                Text(
                  currentTime,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
