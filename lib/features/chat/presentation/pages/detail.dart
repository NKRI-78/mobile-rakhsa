import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/chat/presentation/pages/expire.dart';

import 'package:rakhsa/features/chat/presentation/provider/detail_inbox_notifier.dart';

class InboxDetailPage extends StatefulWidget {
  final int id;
  const InboxDetailPage({super.key,
    required this.id
  });

  @override
  State<InboxDetailPage> createState() => InboxDetailPageState();
}

class InboxDetailPageState extends State<InboxDetailPage> {

  late DetailInboxNotifier detailInboxNotifier;

  Future<void> getData() async {
    if(!mounted) return;
      detailInboxNotifier.getInbox(id: widget.id);
  }

  @override 
  void initState() {
    super.initState();

    detailInboxNotifier = context.read<DetailInboxNotifier>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  String getStatusLabel(dynamic date) {
    if (date == "-") return "";
    
    try {
      final DateTime expiryDate = DateTime.parse(date.toString());
      return expiryDate.isBefore(DateTime.now()) ? "Expired" : "Active";
    } catch (e) {
      return "Invalid Date";
    }
  }

  Color getStatusColor(dynamic date) {
    if (date == null) return Colors.grey;
    
    try {
      final DateTime expiryDate = DateTime.parse(date.toString());
      return expiryDate.isBefore(DateTime.now()) ? Colors.red : Colors.green;
    } catch (e) {
      return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DetailInboxNotifier>(
        builder: (BuildContext context, DetailInboxNotifier notifier, Widget? child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [

              SliverAppBar(
                title: Text("Notification Detail",
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.bold,
                    color: ColorResources.black
                  ),
                ),
                centerTitle: true,
                leading: CupertinoNavigationBarBackButton(
                  color: ColorResources.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              if(notifier.state == ProviderState.loading)
                const SliverFillRemaining(
                  child: Center(
                    child: SpinKitChasingDots(
                      color: primaryColor,
                    )
                  )
                ),

              if(notifier.state == ProviderState.error)
                SliverFillRemaining(
                  child: Center(
                    child: Text(notifier.message,
                      style: robotoRegular.copyWith(
                        color: ColorResources.black,
                        fontSize: Dimensions.fontSizeDefault
                      ),
                    ),
                  ),
                ),

              if(notifier.state == ProviderState.loaded)
                SliverPadding(
                  padding: const EdgeInsets.only(
                    top: 5.0,
                    bottom: 5.0
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      Container(
                        margin: const EdgeInsets.only(
                          top: 12.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        padding: const EdgeInsets.only(
                          top: 12.0,
                          left: 12.0,
                          right: 12.0 
                        ),
                        child: Text(notifier.inbox.field6.toString(),
                          style: robotoRegular.copyWith(
                            color: ColorResources.black,
                            fontSize: Dimensions.fontSizeDefault,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ),
                  
                      Container(
                        margin: const EdgeInsets.only(
                          top: 8.0,
                          left: 16.0,
                          right: 16.0
                        ),
                        padding: const EdgeInsets.only(
                          left: 12.0,
                          right: 12.0,
                          bottom: 5.0
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: SizedBox(
                                width: 200.0,
                                child: Text(notifier.inbox.title.toString(),
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: ColorResources.black
                                  ),
                                ),
                              ),
                            ),

                            ExpiryWidget(
                              field2: notifier.inbox.field2.toString(), 
                              field5: notifier.inbox.field5
                            )
                          ],
                        )
                      ),

                      Container(
                        margin: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0
                        ),
                        child: const Divider(
                          color: Colors.grey,
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0,
                          left: 16.0,
                          right: 16.0
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(notifier.inbox.field4.toString().toUpperCase(),
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: ColorResources.black
                                  ),
                                ),

                                Text("${notifier.inbox.description.toString()}, -",
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: ColorResources.black
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8.0),

                            notifier.inbox.field3 == "va" 
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      color: primaryColor
                                    ),
                                    child: Text(notifier.inbox.link.toString(),
                                      style: robotoRegular.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: ColorResources.white
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6.0),
                                  InkWell(
                                    onTap: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: notifier.inbox.link.toString()
                                      ));
                                      ShowSnackbar.snackbarDefault("${notifier.inbox.link.toString()} disalin");
                                    },
                                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Icon(Icons.copy,
                                        size: 15.0,
                                        color: ColorResources.black,
                                      ),
                                    ),
                                  )
                                ],
                              ) 
                            : CachedNetworkImage(
                                imageUrl: notifier.inbox.link.toString(),
                                imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                  return Container(
                                    width: double.infinity,
                                    height: 330.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: imageProvider
                                      )
                                    ),
                                  );
                                },
                                placeholder: (BuildContext context, String url) {
                                  return Container(
                                    width: double.infinity,
                                    height: 330.0,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: AssetImage('assets/images/default_image.png')
                                      )
                                    ),
                                  );
                                },
                                errorWidget: (BuildContext context, String url, Object error) {
                                  return Container(
                                    width: double.infinity,
                                    height: 330.0,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: AssetImage('assets/images/default_image.png')
                                      )
                                    ),
                                  );
                                },
                              )

                          ],
                        ) 
                      )
                  
                    ])
                  ),
                )

            ],
          );

        },
      ) 
    );
  }
}