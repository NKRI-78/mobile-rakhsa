import 'package:flutter/material.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';
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
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && !isSingleAdmin)
            Row(
              spacing: 6,
              mainAxisSize: MainAxisSize.min,
              children: [
                Avatar(src: username, initial: username, radius: 12),
                Text(
                  username,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 14.0,
            ),
            margin: EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isMe ? primaryColor : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMe ? 12.0 : 0.0),
                topRight: Radius.circular(isMe ? 0.0 : 12.0),
                bottomLeft: const Radius.circular(12.0),
                bottomRight: const Radius.circular(12.0),
              ),
            ),
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: robotoRegular.copyWith(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),

                Text(
                  time,
                  style: robotoRegular.copyWith(
                    color: isMe
                        ? ColorResources.white
                        : ColorResources.black.withValues(alpha: 0.8),
                    fontSize: Dimensions.fontSizeExtraSmall,
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
