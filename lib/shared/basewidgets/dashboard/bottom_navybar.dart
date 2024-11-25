import 'package:flutter/material.dart';
import 'package:rakhsa/common/utils/color_resources.dart';

class BottomNavyBar extends StatelessWidget {
  final int selectedIndex;
  final double iconSize;
  final Color backgroundColor;
  final bool showElevation;
  final Duration animationDuration;
  final List<BottomNavyBarItem> items;
  final ValueChanged<int> onItemSelected;
  final MainAxisAlignment mainAxisAlignment;
  final double itemCornerRadius;
  final double containerHeight;
  final Curve curve;

  const BottomNavyBar({
    super.key, 
    this.selectedIndex = 0,
    this.showElevation = true,
    this.iconSize = 24.0,
    this.backgroundColor = Colors.white,
    this.itemCornerRadius = 10.0,
    this.containerHeight = 70.0,
    this.animationDuration = const Duration(milliseconds: 270),
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    required this.items,
    required this.onItemSelected,
    this.curve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          if (showElevation)
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
            ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: containerHeight,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          children: items.map((item) {
            var index = items.indexOf(item);
            return GestureDetector(
              onTap: () => onItemSelected(index),
              child: ItemWidget(
                item: item,
                iconSize: iconSize,
                isSelected: index == selectedIndex,
                backgroundColor: backgroundColor,
                itemCornerRadius: itemCornerRadius,
                animationDuration: animationDuration,
                curve: curve,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final double iconSize;
  final bool isSelected;
  final BottomNavyBarItem item;
  final Color backgroundColor;
  final double itemCornerRadius;
  final Duration animationDuration;
  final Curve curve;

  const ItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.backgroundColor,
    required this.animationDuration,
    required this.itemCornerRadius,
    required this.iconSize,
    this.curve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: isSelected ? 115 : 50,
      height: double.maxFinite,
      duration: animationDuration,
      curve: curve,
      decoration: BoxDecoration(
        color: isSelected ? item.activeColor : backgroundColor,
        borderRadius: BorderRadius.circular(itemCornerRadius),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          width: isSelected ? 115 : 50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconTheme(
                data: IconThemeData(
                  size: iconSize,
                  color: isSelected
                  ? ColorResources.white
                  : ColorResources.black,
                ),
                child: item.icon,
              ),
              const SizedBox(width: 6.0),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: item.activeColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    textAlign: item.textAlign,
                    child: item.title,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavyBarItem {
  final Icon icon;
  final Text title;
  final Color activeColor;
  final Color inactiveColor;
  final TextAlign textAlign;

  BottomNavyBarItem({
    required this.icon,
    required this.title,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.textAlign = TextAlign.start,
  });
}