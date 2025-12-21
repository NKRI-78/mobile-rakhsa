import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rakhsa/core/constants/assets.dart';

import 'package:rakhsa/modules/information/presentation/pages/passport_visa/passport/passport.dart';
import 'package:rakhsa/modules/information/presentation/pages/passport_visa/visa/visa.dart';
import 'package:rakhsa/modules/information/presentation/pages/widgets/list_card.dart';

class PassportVisaIndexPage extends StatelessWidget {
  final int stateId;

  const PassportVisaIndexPage({required this.stateId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        automaticallyImplyLeading: false,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.black,
          onPressed: context.pop,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 32,
              bottom: 10,
            ),
            child: Text(
              'Informasi mengenai Passport / Visa ?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListCardInformation(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return PassportPage(stateId: stateId);
                  },
                ),
              );
            },
            image: Assets.iconInfo,
            title: "Passport",
          ),
          ListCardInformation(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return VisaPage(stateId: stateId);
                  },
                ),
              );
            },
            image: Assets.iconHukum,
            title: "Visa",
          ),
        ],
      ),
    );
  }
}
