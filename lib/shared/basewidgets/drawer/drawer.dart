import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';

import 'package:rakhsa/shared/basewidgets/button/bounce.dart';

import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/pages/profile.dart';
import 'package:rakhsa/features/chat/presentation/pages/chats.dart';

import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

class DrawerWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey;
  const DrawerWidget({
    required this.globalKey,
    super.key
  });

  @override
  State<DrawerWidget> createState() => DrawerWidgetState();
}

class DrawerWidgetState extends State<DrawerWidget> {
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFC82927),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                context.watch<ProfileNotifier>().state == ProviderState.loading 
                ? const SizedBox() 
                : context.watch<ProfileNotifier>().state == ProviderState.error 
                ? const SizedBox()
                : Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0)
                      ),
                      color: ColorResources.white
                    ),
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
            
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
            
                          CachedNetworkImage(
                            imageUrl: context.read<ProfileNotifier>().entity.data?.avatar ?? "-",
                            imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                              return CircleAvatar(
                                backgroundImage: imageProvider,
                              );
                            },
                            placeholder: (BuildContext context, String url) {
                              return const CircleAvatar(
                                backgroundImage: AssetImage('assets/images/default.jpeg'),
                              );
                            },
                            errorWidget: (BuildContext context, String url, Object error) {
                              return const CircleAvatar(
                                backgroundImage: AssetImage('assets/images/default.jpeg'),
                              );
                            },
                          ),
            
                          const SizedBox(width: 15.0),
            
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
            
                              Text("Nama",
                                style: robotoRegular.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: ColorResources.grey
                                ),
                              ),
            
                              const SizedBox(height: 2.0),
            
                              Text(context.read<ProfileNotifier>().entity.data?.username ?? "-",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  color: ColorResources.black
                                ),
                              ),
            
                            ],
                          ), 
            
                        ],
                      ),
            
                      const SizedBox(height: 15.0),
            
                      CustomButton(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const ProfilePage();
                            },
                          ));
                        },
                        isBorder: true,
                        isBorderRadius: true,
                        height: 40.0,
                        sizeBorderRadius: 8.0,
                        btnBorderColor: ColorResources.greyDarkPrimary,
                        btnColor: ColorResources.white,
                        btnTxt: "Profile",
                        btnTextColor: const Color(0xFFC82927),
                      ),
                      
                    ],
                  ),
                ),
            
                const SizedBox(height: 10.0),
            
                CustomButton(
                  onTap: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                      return const ChatsPage();
                    }));
                  },
                  isBorder: true,
                  isBorderRadius: true,
                  btnColor: ColorResources.transparent,
                  btnBorderColor: ColorResources.white,
                  fontSize: Dimensions.fontSizeDefault,
                  btnTxt: "Notification",
                ),
            
              ],
            ),

            Bouncing(
              child: Image.asset(logoutTitle,
                width: 110.0,
                height: 110.0,
              ), 
              onPress: () async {
                await GeneralModal.logout(globalKey: widget.globalKey);
              }
            )

          ],
        ),
      ),
    );
  }
}