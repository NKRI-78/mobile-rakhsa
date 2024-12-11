import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/information/presentation/pages/widgets/list_card.dart';

class PassportPage extends StatefulWidget {
  final int stateId; 

  const PassportPage({
    required this.stateId,
    super.key
  });

  @override
  State<PassportPage> createState() => PassportPageState();
}

class PassportPageState extends State<PassportPage> {

  @override 
  void initState() {
    super.initState();
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Text('Jelajahi Layanan Passport',
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
              debugPrint("alert");
            },
            image: AssetSource.iconInfo, 
            title: "Passport Baru"
          ),
        ],
      ),
    );
  }
}