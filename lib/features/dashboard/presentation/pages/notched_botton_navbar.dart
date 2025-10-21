import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';

class NotchedBottomNavBar extends StatelessWidget {
  final Widget leftItem;
  final Widget rightItem;
  final double height;
  final Color color;
  final double notchMargin;

  const NotchedBottomNavBar({
    super.key,
    required this.leftItem,
    required this.rightItem,
    this.height = 78,
    this.color = redColor,
    this.notchMargin = 40,
  });

  @override
  Widget build(BuildContext context) {
    // Diameter FAB.large (64) ditambah margin notch
    final double fabSpace = 64 + (notchMargin * 3);

    return BottomAppBar(
      padding: EdgeInsets.zero,
      height: height,
      notchMargin: notchMargin,
      shape: const CircularNotchedRectangle(),
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Item kiri
          Expanded(
            child: Align(alignment: Alignment.center, child: leftItem),
          ),
          // Ruang FAB
          SizedBox(width: fabSpace),
          // Item kanan
          Expanded(
            child: Align(alignment: Alignment.center, child: rightItem),
          ),
        ],
      ),
    );
  }
}
