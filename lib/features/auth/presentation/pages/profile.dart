
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

  late ProfileNotifier profileNotifier;

  Future<void> getData() async {
    if(!mounted) return;
      profileNotifier.getProfile();
  }

  @override 
  void initState() {
    super.initState();

    profileNotifier = context.read<ProfileNotifier>();
    
    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            getData();
          });
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
        
            SliverAppBar(
              backgroundColor: ColorResources.backgroundColor,
              centerTitle: true,
              title: Text("Profile",
                style: robotoRegular.copyWith(
                  color: ColorResources.black,
                  fontSize: Dimensions.fontSizeLarge,
                  fontWeight: FontWeight.bold
                ),
              ),
              leading: CupertinoNavigationBarBackButton(
                color: ColorResources.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(
                left: 16.0, 
                right: 16.0
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        color: ColorResources.white
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
              
                              Expanded(
                                child: Text("Nama",
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.grey,
                                    fontSize: Dimensions.fontSizeDefault
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 3,
                                child: Text("Reihan Agam",
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.black,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
              
                            ],
                          ), 
                    
                          const SizedBox(height: 8.0),
                    
                          const Divider(
                            thickness: 0.5,
                            color: ColorResources.hintColor
                          ),
              
                          const SizedBox(height: 8.0),
              
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
              
                              Expanded(
                                child: Text("E-mail",
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.grey,
                                    fontSize: Dimensions.fontSizeDefault
                                  ),
                                ),
                              ),
              
                              Expanded(
                                flex: 3,
                                child: Text("reihanagam7@gmail.com",
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.black,
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
              
                            ],
                          ), 
                          
                          const SizedBox(height: 8.0),
                    
                          const Divider(
                            thickness: 0.5,
                            color: ColorResources.hintColor
                          ),
              
                          const SizedBox(height: 8.0),
              
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
              
                              Expanded(
                                child: Text("No Tlp",
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.grey,
                                    fontSize: Dimensions.fontSizeDefault
                                  ),
                                ),
                              ),
              
                              Expanded(
                                flex: 3,
                                child: Text("089670558381",
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.black,
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
              
                            ],
                          ), 
              
                        ],
                      )
                    ),
                    
                    const SizedBox(height: 10.0),

                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        color: ColorResources.white
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
              
                              Expanded(
                                flex: 2,
                                child: Text("Kontak darurat",
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.grey,
                                    fontSize: Dimensions.fontSizeDefault
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 3,
                                child: Text("Reihan Agam",
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.black,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
              
                            ],
                          ), 
              
                        ],
                      )
                    ),

                 
                  ],
                )
              )
            ),
        
          ],
        ),
      ),
    );
  }
}