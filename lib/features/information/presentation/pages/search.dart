
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({
    super.key
  });

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  
  late TextEditingController searchC;

  @override 
  void initState() {
    super.initState();

    searchC = TextEditingController();
  }

  @override 
  void dispose() {
    searchC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [

          SliverAppBar(
            backgroundColor: ColorResources.backgroundColor,
            leading: CupertinoNavigationBarBackButton(
              onPressed: () {
                Navigator.pop(context);
              },
              color: ColorResources.black,
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(
                left: 16.0,
                right: 16.0
              ),
              child: Text("Pilih negara terlebih dahulu...",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeOverLarge,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0
              ),
              child: TextField(
                controller: searchC,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColorResources.white,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(9.0))
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(9.0))
                  ),
                  hintStyle: robotoRegular.copyWith(
                    color: ColorResources.grey,
                    fontSize: Dimensions.fontSizeSmall
                  ),
                  hintText: "Cari negara yang Anda inginkan",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: ColorResources.grey,
                  )
                ),
              )
            ),
          )



        ],
      )
    );
  }
}