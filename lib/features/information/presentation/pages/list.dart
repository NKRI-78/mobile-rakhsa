import 'package:flutter/material.dart';

import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/features/information/presentation/pages/search.dart';

import 'package:rakhsa/features/information/presentation/pages/widgets/list_card.dart';

class InformationListPage extends StatelessWidget {
  const InformationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        automaticallyImplyLeading: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.0, 
              right: 20.0, 
              bottom: 10.0
            ),
            child: Text('Informasi apa, yang ingin anda ketahui ?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          )
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListCardInformation(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const SearchPage(info: "informasi-kbri");
              }));
            },
            image: AssetSource.iconInfo, 
            title: "Informasi KBRI"
          ),
          ListCardInformation(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const SearchPage(info: "passport-visa");
              }));
            },
            image: AssetSource.iconCard, 
            title: "Passport & VISA"
          ),
          ListCardInformation(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const SearchPage(info: "panduan-hukum");
              }));
            },
            image: AssetSource.iconHukum, 
            title: "Panduan Hukum"
          ),
        ],
      ),
    );
  }
}