import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/helpers/enum.dart';
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
      dashboardNotifier.getNews();
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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, right: 32, bottom: 10),
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
          if(notifier.state == ProviderState.empty) {
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
              padding: const EdgeInsets.all(16),
              children: [
                Container(
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
                        child: Image.network(
                          notifier.news.first.img.toString(),
                          fit: BoxFit.fitWidth,
                        ),
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
                        bottom: 8,
                        left: 16,
                        right: 16,
                        child: Text(notifier.news.first.title.toString(),
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
                const SizedBox(
                  height: 18,
                ),
            
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifier.news.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context, MaterialPageRoute(
                            builder: (_) => NewsDetailPage(
                              title: notifier.news[i].title.toString(),  
                              img: notifier.news[i].img.toString(),
                              desc: notifier.news[i].desc.toString(),
                            )
                          ));
                        },
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                height: double.infinity,
                                child: Image.network(notifier.news[i].img.toString(),
                                  fit: BoxFit.cover,
                                ),
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
                                      style: robotoRegular.copyWith(
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
                // ...List.generate(5, (index) {
                //   return Padding(
                //     padding: const EdgeInsets.only(
                //       bottom: 12,
                //     ),
                //     child: InkWell(
                //       onTap: () {
                //         Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //                 builder: (_) => const NewsDetailPage()));
                //       },
                //       child: Container(
                //         clipBehavior: Clip.antiAlias,
                //         height: 100,
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(9),
                //         ),
                //         child: Row(
                //           children: [
                //             SizedBox(
                //               width: 100,
                //               height: double.infinity,
                //               child: Image.network(
                //                 'https://i.ytimg.com/vi/4sZeLgimKw0/maxresdefault.jpg',
                //                 fit: BoxFit.cover,
                //               ),
                //             ),
                //             const Expanded(
                //                 child: Padding(
                //               padding: EdgeInsets.symmetric(horizontal: 16.0),
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 children: [
                //                   Text(
                //                     'Alur Jual-Beli Rekening Penampungan Judol dari WNI Dikirim ke Kamboja',
                //                     style: TextStyle(
                //                       fontWeight: FontWeight.w500,
                //                       fontSize: 12.46,
                //                     ),
                //                   ),
                //                   SizedBox(
                //                     height: 6,
                //                   ),
                //                   Text(
                //                     '7 menit yang lalu',
                //                     style: TextStyle(
                //                       fontWeight: FontWeight.w500,
                //                       fontSize: 7,
                //                     ),
                //                   )
                //                 ],
                //               ),
                //             ))
                //           ],
                //         ),
                //       ),
                //     ),
                //   );
                // })
              ],
            ),
          );
        }
      ),
    );
  }
}
