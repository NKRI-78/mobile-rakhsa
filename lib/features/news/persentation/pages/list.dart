import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/features/news/persentation/pages/detail.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => NewsListPageState();
}

class NewsListPageState extends State<NewsListPage> {

  late DashboardNotifier dashboardNotifier;

  Future<void> getData() async {
    if(!mounted) return;
      await dashboardNotifier.getNews(
        lat: 0.0, 
        lng: 0.0
      );
  }

  @override 
  void initState() {
    super.initState();

    dashboardNotifier = context.read<DashboardNotifier>();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        automaticallyImplyLeading: false,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0, 
              right: 32.0,
              bottom: 10.0
            ),
            child: Text('Berita Terkini Seputar Indonesia',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          )
        ),
      ),
      body:  Consumer<DashboardNotifier>(
        builder: (BuildContext context, DashboardNotifier notifier, Widget? child) {
          if(notifier.state == ProviderState.loading) {
            return const Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator()
              )
            );
          }
          if(notifier.state == ProviderState.empty) {
            return Center(
              child: Text("Belum ada berita", 
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorResources.black
                ),
              )
            );
          }
          if(notifier.state == ProviderState.error) {
            return Center(
              child: Text(notifier.message,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorResources.black
                ),
              )
            );
          }
          return RefreshIndicator.adaptive(
            onRefresh: () {
              return Future.sync(() {
                getData();
              });
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigator.pushNamedAndRemoveUntil(context, RoutesNavigation.newsDetail, (route) => route.isFirst, arguments: {
                    //   'id': notifier.news[0].id,
                    //   'type': notifier.news[0].type.toString(),
                    // });
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                      return NewsDetailPage(id: notifier.news[0].id, type: notifier.news[0].type.toString(),);
                    },), (route) => route.isFirst);
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    height: MediaQuery.sizeOf(context).width * .6,
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(9)
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CachedNetworkImage(
                            fit: BoxFit.fitWidth,
                            imageUrl: notifier.news[0].img.toString(),
                            placeholder: (BuildContext context, String url) {
                              return Image.asset('assets/images/default.jpeg');
                            },
                            errorWidget: (BuildContext context, String url, Object error) {
                              return Image.asset('assets/images/default.jpeg');
                            },
                          )
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(.3),
                              Colors.black,
                            ]
                          )
                        )),
                        Positioned(
                          bottom: 8.0,
                          left: 16.0,
                          right: 16.0,
                          child: Text(notifier.news[0].title.toString(),
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18.0,
                ),
            
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notifier.news.length,
                  itemBuilder: (BuildContext context, int i) {
                    if(i == 0) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12.0,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(context, RoutesNavigation.newsDetail, (route) => route.isFirst, arguments: {
                            'id': notifier.news[i].id,
                            'type': notifier.news[i].type.toString(),
                          });
                        },
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          height: 100.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100.0,
                                height: double.infinity,
                                child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                  imageUrl: notifier.news[i].img.toString(),
                                  placeholder: (BuildContext context, String url) {
                                    return Image.asset('assets/images/default.jpeg');
                                  },
                                  errorWidget: (BuildContext context, String url, Object error) {
                                    return Image.asset('assets/images/default.jpeg');
                                  },
                                )
                              ),
                              Expanded(
                                child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      notifier.news[i].title,
                                      maxLines: 3,
                                      style: robotoRegular.copyWith(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w500,
                                        fontSize: Dimensions.fontSizeLarge,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6.0,
                                    ),
                                    Text(notifier.news[i].createdAt,
                                      style: robotoRegular.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    )
                                  ],
                                ),
                              ))
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          );
        }
      ),
    );
  }
}
