import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart' as fh;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/core/extensions/extensions.dart';

import 'package:rakhsa/modules/dashboard/data/models/news.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/modules/ews/persentation/pages/ews_detail_page.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:shimmer/shimmer.dart';

class EwsListWidget extends StatefulWidget {
  const EwsListWidget({super.key});

  @override
  State<EwsListWidget> createState() => _EwsListWidgetState();
}

class _EwsListWidgetState extends State<EwsListWidget> {
  int _currentEwsIndex = 0;

  void _onEwsIndexChanged(int index) {
    if (mounted) {
      _currentEwsIndex = index;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: .circular(16),
      child: Consumer<DashboardNotifier>(
        builder: (context, n, child) {
          final ewsLength = n.ews.length;
          final currentEws = _currentEwsIndex + 1;

          return Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  viewportFraction: 1.0,
                  autoPlayInterval: Duration(seconds: 5),
                  enableInfiniteScroll: ewsLength > 1,
                  onPageChanged: (index, realIndex) {
                    _onEwsIndexChanged(index);
                  },
                ),
                items: n.ews.map((i) => _buildEwsCard(i)).toList(),
              ),

              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: .symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: .circular(4),
                  ),
                  child: Text(
                    "$currentEws/$ewsLength",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: .w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEwsCard(NewsData item) {
    return GestureDetector(
      onTap: () {
        NewsDetailRoute(
          EwsDetailPageParams(id: item.id, type: item.type),
        ).go(context);
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: item.img,
              fit: .cover,
              width: double.maxFinite,
              height: 200.0,
              placeholder: (context, url) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade200,
                  child: Container(color: Colors.grey.shade300),
                );
              },
              errorWidget: (context, url, error) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade200,
                  child: Container(color: Colors.grey.shade300),
                );
              },
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: .topCenter,
                  end: .bottomCenter,
                  colors: [Colors.black26, Colors.black87],
                ),
              ),
            ),
          ),

          Padding(
            padding: .all(16),
            child: Column(
              spacing: 2,
              mainAxisAlignment: .end,
              crossAxisAlignment: .stretch,
              children: [
                Expanded(
                  child: Text(
                    "Info kejadian disekitar Anda",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: .bold,
                    ),
                  ),
                ),

                Text(
                  item.createdAt,
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),

                if (item.location.isNotEmpty && item.location != "-")
                  Row(
                    spacing: 4,
                    children: [
                      Icon(
                        IconsaxPlusBold.location,
                        color: Colors.white,
                        size: 14,
                      ),
                      Expanded(
                        child: Text(
                          item.location,
                          overflow: .ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ),

                5.spaceY,

                Text(
                  item.title,
                  overflow: .ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: .bold,
                  ),
                ),

                Flexible(
                  child: fh.Html(
                    data: item.desc,
                    shrinkWrap: true,
                    style: {
                      'body': fh.Style(
                        color: Colors.white.withValues(alpha: 0.8),
                        maxLines: 2,
                        margin: fh.Margins.zero,
                        padding: fh.HtmlPaddings.zero,
                        fontSize: fh.FontSize(11),
                        textOverflow: .ellipsis,
                      ),
                      'p': fh.Style(
                        margin: fh.Margins.zero,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: fh.FontSize(10),
                        display: fh.Display.inline,
                        fontWeight: .normal,
                      ),
                      'span': fh.Style(
                        margin: fh.Margins.zero,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: fh.FontSize(12),
                        display: fh.Display.inline,
                      ),
                      'div': fh.Style(
                        margin: fh.Margins.zero,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: fh.FontSize(12),
                        display: fh.Display.inline,
                      ),
                      'strong': fh.Style(fontWeight: .normal),
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
