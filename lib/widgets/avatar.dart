import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/misc/constants/theme.dart';

class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    required this.src,
    this.initial,
    this.radius = 20.0,
    this.withBorder = false,
    this.borderColor = blackColor,
  });

  final String src;
  final String? initial;
  final double radius;
  final bool withBorder;
  final Color borderColor;

  final _radiusFactor = 2.0;

  double get actualHeight => _radiusFactor * radius;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  late Color _backgroundColor;
  late String _randomLetter;

  @override
  void initState() {
    super.initState();
    _backgroundColor = _getRandomShade();
    _randomLetter = _getRandomCapitalLetter();
  }

  String _getRandomCapitalLetter() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return letters[random.nextInt(letters.length)];
  }

  String? _getInitials() {
    if (widget.initial == null) return null;
    final words = widget.initial!.trim().split(RegExp(r'\s+'));
    final firstTwoWords = words.take(2);
    final initials = firstTwoWords.map((word) {
      if (word.isEmpty) return '';
      final firstChar = word[0];
      return firstChar.toUpperCase();
    }).join();
    return initials;
  }

  Color _getRandomShade() {
    final random = Random();
    final materialColors = <MaterialColor>[
      Colors.red,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
      Colors.grey,
    ];
    final color = materialColors[random.nextInt(materialColors.length)];
    return color.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final minDiameter = widget._radiusFactor * widget.radius;
    final maxDiameter = widget._radiusFactor * widget.radius;

    final loadAndErrorWidget = AnimatedContainer(
      duration: kThemeAnimationDuration,
      alignment: Alignment.center,
      constraints: BoxConstraints(
        minHeight: minDiameter,
        minWidth: minDiameter,
        maxWidth: maxDiameter,
        maxHeight: maxDiameter,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _backgroundColor,
        border: widget.withBorder ? Border.all(color: greyColor) : null,
      ),
      child: Text(
        _getInitials() ?? _randomLetter,
        style: TextStyle(
          color: whiteColor,
          fontSize: minDiameter >= 90 ? 32.0 : 18.0,
        ),
      ),
    );

    return CachedNetworkImage(
      imageUrl: widget.src,
      fit: BoxFit.cover,
      imageBuilder: (context, imageProvider) {
        return AnimatedContainer(
          duration: kThemeAnimationDuration,
          padding: widget.withBorder ? EdgeInsets.all(1) : null,
          constraints: BoxConstraints(
            minHeight: minDiameter,
            minWidth: minDiameter,
            maxWidth: maxDiameter,
            maxHeight: maxDiameter,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _backgroundColor,
            border: widget.withBorder
                ? Border.all(color: widget.borderColor)
                : null,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      },
      placeholder: (context, url) {
        return loadAndErrorWidget;
      },
      errorWidget: (context, url, error) {
        return loadAndErrorWidget;
      },
    );
  }
}
