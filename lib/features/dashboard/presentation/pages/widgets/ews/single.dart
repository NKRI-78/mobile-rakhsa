import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart' as fh;
import 'package:provider/provider.dart'; 

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/features/news/persentation/pages/detail.dart';

class EwsSingleWidget extends StatelessWidget {
  final Function getData;

  const EwsSingleWidget({
    required this.getData,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardNotifier>(
      builder: (BuildContext context, DashboardNotifier notifier, Widget? child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return NewsDetailPage(
                  id: notifier.ews.first.id,
                  type: notifier.ews.first.type.toString(),
                );
              },
            )).then((value) {
              if(value != null) {
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
              imageUrl: notifier.ews.first.img.toString(),
              imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: imageProvider,
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Info Kejadian di sekitar Anda",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: ColorResources.white
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              notifier.ews.first.location.toString(),
                              maxLines: 1,
                              style: robotoRegular.copyWith(
                                color: ColorResources.white,
                                fontSize: Dimensions.fontSizeDefault,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              notifier.ews.first.createdAt.toString(),
                              style: robotoRegular.copyWith(
                                color: ColorResources.white.withOpacity(0.8),
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              notifier.ews.first.title.toString(),
                              style: robotoRegular.copyWith(
                                color: ColorResources.white,
                                fontSize: Dimensions.fontSizeDefault,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            fh.Html(
                              data: notifier.ews.first.desc.toString(),
                              shrinkWrap: true,
                              style: {
                                'body': fh.Style(
                                  maxLines: 2,
                                  margin: fh.Margins.zero,
                                  textOverflow: TextOverflow.ellipsis,
                                  color: ColorResources.white.withOpacity(0.8),
                                  fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                ),
                                'p': fh.Style(
                                  maxLines: 2,
                                  textOverflow: TextOverflow.ellipsis,
                                  margin: fh.Margins.zero,
                                  color: ColorResources.white.withOpacity(0.8),
                                  fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                ),
                                'span': fh.Style(
                                  maxLines: 2,
                                  textOverflow: TextOverflow.ellipsis,
                                  margin: fh.Margins.zero,
                                  color: ColorResources.white.withOpacity(0.8),
                                  fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                ),
                                'div': fh.Style(
                                  maxLines: 2,
                                  textOverflow: TextOverflow.ellipsis,
                                  margin: fh.Margins.zero,
                                  color: ColorResources.white.withOpacity(0.8),
                                  fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                )
                              },
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
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ],
                  ),
                );
              },
              errorWidget: (BuildContext context, String url, Object error) {
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
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          ),
        );
      },
    );
  }
}