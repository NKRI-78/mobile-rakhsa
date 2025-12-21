import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rakhsa/core/constants/assets.dart';
import 'package:rakhsa/modules/information/presentation/pages/passport_visa/visa/tatacara.dart';

import 'package:rakhsa/modules/information/presentation/pages/widgets/list_card.dart';

class VisaPage extends StatefulWidget {
  final int stateId;

  const VisaPage({required this.stateId, super.key});

  @override
  State<VisaPage> createState() => VisaPageState();
}

class VisaPageState extends State<VisaPage> {
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
              'Perihal Pengajuan VISA bagi WNI',
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
                  builder: (BuildContext context) {
                    return TataCaraPage(stateId: widget.stateId.toString());
                  },
                ),
              );
            },
            image: Assets.iconHukum,
            title: "Tatacara Pembuatan Visa",
          ),
        ],
      ),
    );
  }
}
