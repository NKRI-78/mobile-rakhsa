import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_html/flutter_html.dart' as fh;

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';

class NewsDetailPage extends StatefulWidget {
  final String title; 
  final String img; 
  final String desc;
  final String location;
  final String createdAt;
  final String type;

  const NewsDetailPage({
    required this.title, 
    required this.img,
    required this.desc,
    required this.location,
    required this.createdAt,
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
      dashboardNotifier.getNews(
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(didPop) {
          return;
        }
        Navigator.pop(context, "refetch");
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF4F4F7),
        appBar: AppBar(
          backgroundColor: const Color(0xffF4F4F7),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () {
              Navigator.pop(context, "refetch");
            },
            color: ColorResources.black,
          ),
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
              height: 12.0,
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
            const SizedBox(height: 18.0),
            Text(widget.location,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: ColorResources.black
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(widget.createdAt,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: ColorResources.black
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            fh.Html(
              data: widget.desc,
              style: {
                'body': fh.Style(
                  margin: fh.Margins.zero,
                  fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                ),
                'p': fh.Style(
                  margin: fh.Margins.zero,
                  fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                ),
                'span': fh.Style(
                  margin: fh.Margins.zero,
                  fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                ),
                'div': fh.Style(
                  margin: fh.Margins.zero,
                  fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                )
              },
            ),
            
            widget.type == "ews" 
            ? const SizedBox()  
            : const SizedBox(
                height: 18,
              ),
            widget.type == "ews"  
            ? const SizedBox()
            : const Text('Baca Berita Lainnya',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            widget.type == "ews" 
            ? const SizedBox() 
            : const SizedBox(
              height: 18,
            ),
            widget.type == "ews" 
            ? const SizedBox() 
            : Consumer<DashboardNotifier>(
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
                  physics: const NeverScrollableScrollPhysics(),
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
                              location: notifier.news[i].location,
                              createdAt: notifier.news[i].createdAt,
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
                                    Text(notifier.news[i].title.toString(),
                                      style: robotoRegular.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                    ),
                                    
                                    const SizedBox(
                                      height: 6.0,
                                    ),

                                    fh.Html(
                                      data: notifier.news[i].desc.toString(),
                                      style: {
                                        'body': fh.Style(
                                          maxLines: 1,
                                          margin: fh.Margins.zero,
                                          fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                        ),
                                        'p': fh.Style(
                                          maxLines: 1,
                                          margin: fh.Margins.zero,
                                          fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                        ),
                                        'span': fh.Style(
                                           maxLines: 1,
                                          fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                        ),
                                        'div': fh.Style(
                                         maxLines: 1,
                                          fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                        )
                                      },
                                    ),

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
      ),
    );
  }
}
