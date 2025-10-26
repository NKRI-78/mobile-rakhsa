import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart' as fh;
import 'package:provider/provider.dart';

import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/modules/news/persentation/pages/detail.dart';

class EwsListWidget extends StatelessWidget {
  final Function getData;

  const EwsListWidget({required this.getData, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardNotifier>(
      builder:
          (BuildContext context, DashboardNotifier notifier, Widget? child) {
            return CarouselSlider(
              options: CarouselOptions(
                autoPlayInterval: const Duration(seconds: 5),
                autoPlay: true,
                enableInfiniteScroll: (notifier.ews.length == 1) ? false : true,
                viewportFraction: 1.0,

                height: 200.0,
              ),
              items: notifier.ews.map((item) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return NewsDetailPage(
                            id: item.id,
                            type: item.type.toString(),
                          );
                        },
                      ),
                    ).then((value) {
                      if (value != null) {
                        getData();
                      }
                    });
                  },
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    elevation: 1.0,
                    child: CachedNetworkImage(
                      imageUrl: item.img.toString(),
                      imageBuilder:
                          (
                            BuildContext context,
                            ImageProvider<Object> imageProvider,
                          ) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: imageProvider,
                                ),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Info Kejadian di sekitar Anda",
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            fontWeight: FontWeight.bold,
                                            color: ColorResources.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          item.location.toString(),
                                          maxLines: 1,
                                          style: robotoRegular.copyWith(
                                            color: ColorResources.white,
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          item.createdAt.toString(),
                                          style: robotoRegular.copyWith(
                                            color: ColorResources.white
                                                .withValues(alpha: 0.8),
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          item.title.toString(),
                                          maxLines: 2,
                                          style: robotoRegular.copyWith(
                                            color: ColorResources.white,
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                          child: OverflowBox(
                                            alignment: Alignment.topLeft,
                                            maxHeight: 20,
                                            child: fh.Html(
                                              data: item.desc.toString(),
                                              shrinkWrap: true,
                                              style: {
                                                'body': fh.Style(
                                                  margin: fh.Margins.zero,
                                                  color: ColorResources.white
                                                      .withValues(alpha: 0.8),
                                                  fontSize: fh.FontSize(
                                                    Dimensions.fontSizeSmall,
                                                  ),
                                                  display: fh.Display.inline,
                                                ),
                                                'p': fh.Style(
                                                  margin: fh.Margins.zero,
                                                  color: ColorResources.white
                                                      .withValues(alpha: 0.8),
                                                  fontSize: fh.FontSize(
                                                    Dimensions.fontSizeSmall,
                                                  ),
                                                  display: fh.Display.inline,
                                                ),
                                                'span': fh.Style(
                                                  margin: fh.Margins.zero,
                                                  color: ColorResources.white
                                                      .withValues(alpha: 0.8),
                                                  fontSize: fh.FontSize(
                                                    Dimensions.fontSizeSmall,
                                                  ),
                                                  display: fh.Display.inline,
                                                ),
                                                'div': fh.Style(
                                                  margin: fh.Margins.zero,
                                                  color: ColorResources.white
                                                      .withValues(alpha: 0.8),
                                                  fontSize: fh.FontSize(
                                                    Dimensions.fontSizeSmall,
                                                  ),
                                                  display: fh.Display.inline,
                                                ),
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                      placeholder: (BuildContext context, String url) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: const DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: AssetImage('assets/images/default.jpeg'),
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      errorWidget:
                          (BuildContext context, String url, Object error) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: const DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: AssetImage(
                                    'assets/images/default.jpeg',
                                  ),
                                ),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                    ),
                  ),
                );
              }).toList(),
            );
          },
    );
  }
}
