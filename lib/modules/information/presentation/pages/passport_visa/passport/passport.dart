import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rakhsa/core/constants/assets.dart';

import 'package:rakhsa/modules/information/presentation/pages/passport_visa/passport/info.dart';
import 'package:rakhsa/modules/information/presentation/pages/widgets/list_card.dart';

class PassportPage extends StatefulWidget {
  final int stateId;

  const PassportPage({required this.stateId, super.key});

  @override
  State<PassportPage> createState() => PassportPageState();
}

class PassportPageState extends State<PassportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: .fromLTRB(16, 16, 32, 10),
            child: Text(
              'Jelajahi Layanan Passport',
              style: TextStyle(fontWeight: .bold, fontSize: 24),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const .all(16),
        children: [
          ListCardInformation(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return PassportInfoPage(stateId: widget.stateId.toString());
                  },
                ),
              );
            },
            image: Assets.iconInfo,
            title: "Passport Baru",
          ),
        ],
      ),
    );
  }
}
