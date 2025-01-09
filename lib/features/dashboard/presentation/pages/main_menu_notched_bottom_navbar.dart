import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
 
class MainMenuNotchedBottomNavBar extends StatelessWidget {
  const MainMenuNotchedBottomNavBar({
    super.key,
    required this.onTap,
  });
 
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      elevation: 0,
      highlightElevation: 0,
      backgroundColor: redColor,
      shape: const CircleBorder(),
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 3,
            color: Colors.black.withOpacity(0.1),
          ),
        ),
        child: Image.asset(AssetSource.iconNavBarMainMenu),
      ),
    );
  }
}