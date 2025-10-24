import 'dart:async';
import 'package:flutter/material.dart';

import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

class ExpiryWidget extends StatefulWidget {
  final dynamic field2;
  final dynamic field5;

  const ExpiryWidget({super.key, required this.field2, required this.field5});

  @override
  ExpiryWidgetState createState() => ExpiryWidgetState();
}

class ExpiryWidgetState extends State<ExpiryWidget> {
  late ValueNotifier<String> countdownNotifier;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    countdownNotifier = ValueNotifier<String>(
      calculateCountdown(widget.field5),
    );

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdownNotifier.value = calculateCountdown(widget.field5);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    countdownNotifier.dispose();
    super.dispose();
  }

  String calculateCountdown(dynamic date) {
    if (date == null) return "";

    try {
      final DateTime expiryDate = DateTime.parse(date.toString());
      final Duration diff = expiryDate.difference(DateTime.now());

      if (diff.isNegative) {
        return "Expired";
      }

      // int days = diff.inDays;
      int hours = diff.inHours % 24;
      int minutes = diff.inMinutes % 60;
      int seconds = diff.inSeconds % 60;

      return "${hours}h ${minutes}m ${seconds}s";
    } catch (e) {
      return "";
    }
  }

  Color getStatusColor(dynamic date) {
    if (date == null) return Colors.grey;

    try {
      final DateTime expiryDate = DateTime.parse(date.toString());
      return expiryDate.isBefore(DateTime.now()) ? Colors.red : Colors.black;
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.field2.toString(),
          maxLines: 2,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5.0),
        ValueListenableBuilder<String>(
          valueListenable: countdownNotifier,
          builder: (context, countdownText, child) {
            return Text(
              countdownText,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                fontWeight: FontWeight.bold,
                color: getStatusColor(widget.field5),
              ),
            );
          },
        ),
      ],
    );
  }
}
