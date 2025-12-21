import 'package:flutter/material.dart';
import 'package:rakhsa/core/constants/colors.dart';
import 'package:rakhsa/core/extensions/extensions.dart';

class NearMePlaceType {
  final String title;
  final String assets;
  final VoidCallback action;

  NearMePlaceType(this.title, this.assets, this.action);
}

class NearMePlaceTile extends StatelessWidget {
  const NearMePlaceTile(this.type, {super.key});

  final NearMePlaceType type;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: type.action,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIconAsset(),
              16.spaceX,

              _buildTitle(),

              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Flexible(
      fit: FlexFit.tight,
      child: Text(
        type.title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildIconAsset() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
        ),
      ),
      child: Image.asset(
        type.assets,
        color: Colors.white,
        width: 32,
        height: 32,
      ),
    );
  }
}
