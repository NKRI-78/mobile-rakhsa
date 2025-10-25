import 'package:flutter/material.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:shimmer/shimmer.dart';

import 'dialog.dart';

class DialogCard extends StatelessWidget {
  DialogCard(this.content, {super.key})
    : assert(
        content.title == null || content.titleAsync == null,
        "AppDialog: Ga boleh mengisi title & titleAsync secara bersamaan",
      ),
      assert(
        content.message == null || content.messageAsync == null,
        "AppDialog: Ga boleh mengisi message & messageAsync secara bersamaan",
      );

  final DialogContent content;

  final _defaultIconSize = 100.0;
  final _defaultBorderRadius = 16.0;
  final _defaultContentPadding = 16.0;
  final _defaultBackgroundIconColor = blackColor;
  final _defaultBackgroundColor = whiteColor;
  final _defaultTitleStyle = TextStyle(
    color: blackColor,
    fontSize: fontSizeOverLarge,
    fontWeight: FontWeight.bold,
  );
  final _defaultMessageStyle = TextStyle(color: Colors.black87, fontSize: 13);

  @override
  Widget build(BuildContext context) {
    final hasIcon = content.assetIcon != null;

    final padding = content.style?.contentPadding ?? _defaultContentPadding;
    final iconSize = content.style?.assetIconSize ?? _defaultIconSize;
    final topMargin = hasIcon ? (iconSize / 2) : 0.0;
    final topPadding = hasIcon ? ((iconSize / 2) + padding) : padding;

    final backgroundColor =
        content.style?.backgroundColor ?? _defaultBackgroundColor;
    final backgroundIconColor =
        content.style?.backgroundIconColor ?? _defaultBackgroundIconColor;
    final borderRadius = content.style?.borderRadius ?? _defaultBorderRadius;
    final titleStyle = content.style?.titleStyle ?? _defaultTitleStyle;
    final messageStyle = content.style?.messageStyle ?? _defaultMessageStyle;

    final filteredActions = content.actions.length > 2
        ? content.actions.sublist(0, 2)
        : content.actions;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(padding, topPadding, padding, padding),
            margin: EdgeInsets.only(top: topMargin),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (content.title != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: padding),
                    child: Text(
                      content.title!,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                  ),

                if (content.titleAsync != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: padding),
                    child: _renderAsyncTitle(titleStyle),
                  ),

                if (content.message == null && content.messageAsync == null)
                  Text(
                    "Tulis message diparameter message atau messageAsync",
                    maxLines: 8,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: messageStyle,
                  ),

                if (content.message != null)
                  Text(
                    content.message!,
                    maxLines: 8,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: messageStyle,
                  ),

                if (content.messageAsync != null)
                  _renderAsyncMessage(messageStyle),

                if (filteredActions.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: (padding + 4)),
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: filteredActions.map((button) {
                        final expand =
                            (content.style?.enableExpandPrimaryActionButton ??
                                false) &&
                            button.primary;
                        return Flexible(
                          fit: expand ? FlexFit.tight : FlexFit.loose,
                          child: button,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          if (hasIcon)
            Container(
              decoration: BoxDecoration(
                color: (content.style?.enableBackgroundIcon ?? false)
                    ? backgroundIconColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                content.assetIcon!,
                width: iconSize,
                height: iconSize,
              ),
            ),
        ],
      ),
    );
  }

  Widget _renderAsyncTitle(TextStyle style) {
    return FutureBuilder(
      future: content.titleAsync,
      builder: (context, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return _renderLoadingSkeleton(height: 16);
        }
        if (s.connectionState == ConnectionState.done && s.hasData) {
          return Text(
            s.data!,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: style,
          );
        }
        return Text("-", textAlign: TextAlign.center, style: style);
      },
    );
  }

  Widget _renderAsyncMessage(TextStyle style) {
    return FutureBuilder(
      future: content.messageAsync,
      builder: (context, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return Column(
            spacing: 5,
            mainAxisSize: MainAxisSize.min,
            children: [
              _renderLoadingSkeleton(width: 130),
              _renderLoadingSkeleton(width: 150),
            ],
          );
        }
        if (s.connectionState == ConnectionState.done && s.hasData) {
          return Text(
            s.data!,
            maxLines: 9,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: style,
          );
        }
        return Text("-", textAlign: TextAlign.center, style: style);
      },
    );
  }

  Widget _renderLoadingSkeleton({double width = 60.0, double height = 14.0}) {
    return Shimmer.fromColors(
      highlightColor: Colors.grey.shade100,
      baseColor: Colors.grey.shade300,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
