import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/administration/presentation/provider/get_country_notifier.dart';
import 'package:rakhsa/features/information/presentation/pages/kbri.dart';
import 'package:rakhsa/features/information/presentation/pages/passport_visa.dart';

class SearchPage extends StatefulWidget {
  final String info;

  const SearchPage({
    required this.info,
    super.key
  });

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {

  Timer? debounce;

  late GetCountryNotifier countryNotifier;
  late TextEditingController searchC;

  @override 
  void initState() {
    super.initState();

    countryNotifier = context.read<GetCountryNotifier>();
    countryNotifier.clear();

    searchC = TextEditingController();
  }

  @override 
  void dispose() {
    searchC.dispose();
    debounce?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      body: Consumer<GetCountryNotifier>(
        builder: (BuildContext context, GetCountryNotifier notifier, Widget? child) {
      
          return CustomScrollView(
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
                    onChanged: (String val) async {
                      if (debounce?.isActive ?? false) debounce?.cancel();
                        debounce = Timer(const Duration(milliseconds: 500), () {
                          countryNotifier.getCountry(search: val);
                        });
                    },
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
              ),

              if(notifier.state == ProviderState.loading)
                const SliverFillRemaining(
                  child: Center(
                    child: SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFFFE1717)),
                      )
                    ),
                  ),
                ),

              if(notifier.state == ProviderState.loaded)
                SliverList.builder(
                  itemCount: notifier.entity.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Container(
                      margin: const EdgeInsets.only(
                        top: 10.0,
                        left: 16.0,
                        right: 16.0
                      ),
                      decoration: const BoxDecoration(
                        color: ColorResources.white
                      ),
                      child: Material(
                        color: ColorResources.transparent,
                        child: InkWell(
                          onTap: () {
                            switch(widget.info) {
                              case "informasi-kbri":
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return const KbriPage(); 
                                }));
                              break;  
                              case "passport-visa":
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return PassportVisaPage(countryCode: notifier.entity[i].id);
                                }));
                              break;
                              case "panduan-hukum": 
                              break;
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            
                                const Icon(
                                  Icons.flag,
                                  color: ColorResources.black,
                                  size: 16.0,
                                ),
                            
                                const SizedBox(width: 5.0),
                            
                                Text(notifier.entity[i].name,
                                  style: robotoRegular.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: ColorResources.black
                                  ),
                                )
                            
                              ],
                            ),
                          ),
                        ),
                      )
                    );
                  },
                ),
            
            ],
          );
        },
      ) 
    );
  }
}