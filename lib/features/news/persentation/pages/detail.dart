import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';

class NewsDetailPage extends StatefulWidget {
  final String title; 
  final String img; 
  final String desc;
  final String type;

  const NewsDetailPage({
    required this.title, 
    required this.img,
    required this.desc,
    required this.type,
    super.key
  });

  @override
  State<NewsDetailPage> createState() => NewsDetailPageState();
}

class NewsDetailPageState extends State<NewsDetailPage> {

  late DashboardNotifier dashboardNotifier; 

  Future<void> getData() async {
    if(!mounted) return;
      dashboardNotifier.getNews(type: widget.type, lat: 0.0, lng: 0.0);
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.title,
            style: robotoRegular.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            height: MediaQuery.sizeOf(context).width * .6,
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(9.0)
            ),
            child: Image.network(widget.img,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Text(widget.desc,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: ColorResources.black
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          const Text(
            'Baca Berita Lainnya',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Consumer<DashboardNotifier>(
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
                return const SizedBox();
              } 
              return ListView.builder(
                shrinkWrap: true,
                itemCount: notifier.news.length,
                itemBuilder: (BuildContext context, int i) {
                  if(notifier.news[i].id == 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (_) => NewsDetailPage(
                            title: notifier.news[i].title,
                            img: notifier.news[i].img,
                            desc: notifier.news[i].desc,
                            type: notifier.news[i].type,
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
                              child: CachedNetworkImage(
                                fit: BoxFit.fitWidth,
                                imageUrl: notifier.news[i].img.toString(),
                                placeholder: (context, url) {
                                  return Image.asset('assets/images/default.jpeg');
                                },
                                errorWidget: (context, url, error) {
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
                                  Text(notifier.news[i].title.toString(),
                                    style: robotoRegular.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6.0,
                                  ),
                                  Text(notifier.news[i].desc.toString(),
                                    overflow: TextOverflow.ellipsis,
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
              );
            },
          )
        ],
      ),
    );
  }
}
