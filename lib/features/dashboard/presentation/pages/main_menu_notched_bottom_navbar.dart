
import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/asset_source.dart';

class MainMenuNotchedBottomNavBar extends StatelessWidget {
  const MainMenuNotchedBottomNavBar({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  static FloatingActionButtonLocation get position => _FABPosition();

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

class _FABPosition extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final size = scaffoldGeometry.scaffoldSize;
    final fabSize = scaffoldGeometry.floatingActionButtonSize;

    return Offset(
      (size.width - fabSize.width) / 2, // FAB tepat di tengah secara horizontal
      size.height - fabSize.height - 8, // FAB di dekat bawah dengan margin 16
    );
  }
  
}