import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/information/presentation/widgets/list_card.dart';

class PassportVisaPage extends StatelessWidget {
  final int countryCode;

  const PassportVisaPage({
    required this.countryCode,
    super.key
  });
 
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        automaticallyImplyLeading: false,
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0, 
              right: 32, 
              bottom: 10
          ),
            child: Text('Informasi mengenai Passport / Visa ?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Dimensions.fontSizeOverLarge,
              ),
            ),
          )
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListCardInformation(
            onTap: () {
            
            },
            image: AssetSource.iconInfo, 
            title: "Passport"
          ),
          ListCardInformation(
            onTap: () {
             
            },
            image: AssetSource.iconHukum, 
            title: "Visa"
          ),
        ],
      ),
    );
  }
}