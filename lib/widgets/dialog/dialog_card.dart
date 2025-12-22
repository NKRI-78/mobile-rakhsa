import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'dialog.dart';

class DialogCard extends StatelessWidget {
  DialogCard(this.content, {super.key})
    : assert(
        content?.title == null || content?.titleAsync == null,
        "AppDialog: Ga boleh mengisi title & titleAsync secara bersamaan",
      ),
      assert(
        content?.message == null || content?.messageAsync == null,
        "AppDialog: Ga boleh mengisi message & messageAsync secara bersamaan",
      );

  final DialogContent? content;

  final _defaultIconSize = 100.0;
  final _defaultBorderRadius = 16.0;
  final _defaultContentPadding = 16.0;
  final _defaultBackgroundColor = Colors.white;
  final _defaultActionButtonDirection = Axis.horizontal;
  final _defaultTitleStyle = TextStyle(
    color: Colors.black,
    fontSize: 22,
    fontWeight: .bold,
  );
  final _defaultMessageStyle = TextStyle(color: Colors.black87, fontSize: 13);

  @override
  Widget build(BuildContext context) {
    final hasIcon = content?.assetIcon != null;

    final padding = content?.style?.contentPadding ?? _defaultContentPadding;
    final iconSize = content?.style?.assetIconSize ?? _defaultIconSize;
    final topMargin = hasIcon ? (iconSize / 2) : 0.0;
    final topPadding = hasIcon ? ((iconSize / 2) + padding) : padding;

    final backgroundColor =
        content?.style?.backgroundColor ?? _defaultBackgroundColor;
    final borderRadius = content?.style?.borderRadius ?? _defaultBorderRadius;
    final titleStyle = content?.style?.titleStyle ?? _defaultTitleStyle;
    final messageStyle = content?.style?.messageStyle ?? _defaultMessageStyle;

    final actionDirections =
        content?.actionButtonDirection ?? _defaultActionButtonDirection;
    final actions = content?.buildActions?.call(context) ?? [];
    var filteredActions = <DialogActionButton>[];
    if (actions.isNotEmpty) {
      filteredActions = (actions.length > 2 ? actions.sublist(0, 2) : actions);
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: .topCenter,
        children: [
          Container(
            padding: .fromLTRB(padding, topPadding, padding, padding),
            margin: .only(top: topMargin),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: .circular(borderRadius),
            ),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                if (content?.title != null)
                  Padding(
                    padding: .only(bottom: padding),
                    child: Text(
                      content!.title!,
                      maxLines: 2,
                      textAlign: .center,
                      overflow: .ellipsis,
                      style: titleStyle,
                    ),
                  ),

                if (content?.titleAsync != null)
                  Padding(
                    padding: .only(bottom: padding),
                    child: _renderAsyncTitle(titleStyle),
                  ),

                if (content?.message == null &&
                    content?.messageAsync == null &&
                    content?.messageWidget == null)
                  Text(
                    "Buat message diparameter messageWidget, message atau messageAsync",
                    maxLines: 8,
                    textAlign: .center,
                    overflow: .ellipsis,
                    style: messageStyle,
                  ),

                if (content?.messageWidget != null) content!.messageWidget!,

                if (content?.message != null && content?.messageWidget == null)
                  Text(
                    content!.message!,
                    maxLines: 8,
                    textAlign: .center,
                    overflow: .ellipsis,
                    style: messageStyle,
                  ),

                if (content?.messageAsync != null &&
                    content?.messageWidget == null)
                  _renderAsyncMessage(messageStyle),

                if (filteredActions.isNotEmpty)
                  Padding(
                    padding: .only(top: (padding + 4)),
                    child: actionDirections == .vertical
                        ? Column(
                            spacing: 2,
                            mainAxisSize: .min,
                            crossAxisAlignment: .stretch,
                            children: filteredActions.reversed.toList(),
                          )
                        : Row(
                            spacing: 6,
                            mainAxisAlignment: .center,
                            children: filteredActions.map((button) {
                              final expand =
                                  (content
                                          ?.style
                                          ?.enableExpandPrimaryActionButton ??
                                      false) &&
                                  button.primary;
                              return Flexible(
                                fit: expand ? .tight : .loose,
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
                color:
                    content?.style?.backgroundIconColor ?? Colors.transparent,
                shape: .circle,
              ),
              child: Image.asset(
                content!.assetIcon!,
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
      future: content?.titleAsync,
      builder: (context, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return _renderLoadingSkeleton(height: 16);
        }
        if (s.connectionState == ConnectionState.done && s.hasData) {
          return Text(
            s.data!,
            maxLines: 2,
            textAlign: .center,
            overflow: .ellipsis,
            style: style,
          );
        }
        return Text("-", textAlign: .center, style: style);
      },
    );
  }

  Widget _renderAsyncMessage(TextStyle style) {
    return FutureBuilder(
      future: content?.messageAsync,
      builder: (context, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return Column(
            spacing: 5,
            mainAxisSize: .min,
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
            textAlign: .center,
            overflow: .ellipsis,
            style: style,
          );
        }
        return Text("-", textAlign: .center, style: style);
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
          borderRadius: .circular(4),
        ),
      ),
    );
  }
}
