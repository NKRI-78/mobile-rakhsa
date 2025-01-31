import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';
 
class NotchedBottomNavBar extends StatelessWidget {
  const NotchedBottomNavBar({
    super.key,
    required this.menus,
    required this.navBarHeight,
  });
 
  final List<Widget> menus;
  final double navBarHeight;
 
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 78,
      notchMargin: 40,
      shape: const CircularNotchedRectangle(),
      color: redColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: menus,
        ),
      ),
    );
  }
}