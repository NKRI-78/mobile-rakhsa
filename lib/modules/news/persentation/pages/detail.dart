import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';

import 'package:flutter_html/flutter_html.dart' as fh;
import 'package:rakhsa/misc/constants/theme.dart';

import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';

import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/detail_news_notifier.dart';

class NewsDetailPageParams {
  final int id;
  final String type;

  NewsDetailPageParams({required this.id, required this.type});
}

class NewsDetailPage extends StatefulWidget {
  final int id;
  final String type;

  const NewsDetailPage({required this.id, required this.type, super.key});

  @override
  State<NewsDetailPage> createState() => NewsDetailPageState();
}

class NewsDetailPageState extends State<NewsDetailPage> {
  late DetailNewsNotifier detailNewsNotifier;

  @override
  void initState() {
    super.initState();

    detailNewsNotifier = context.read<DetailNewsNotifier>();

    Future.microtask(() => getData());
  }

  Future<void> getData() async {
    if (!mounted) return;
    await detailNewsNotifier.detailNews(id: widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Detail Berita"),
        backgroundColor: Colors.grey.shade50,
      ),
      body: Consumer<DetailNewsNotifier>(
        builder: (context, notifier, child) {
          if (notifier.state != ProviderState.loaded) {
            return Center(
              child: Column(
                spacing: 16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  Text(
                    "Memuat data..",
                    style: TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          final data = notifier.entity;

          return RefreshIndicator.adaptive(
            onRefresh: getData,
            color: primaryColor,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, context.bottom + 16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: data.img ?? "",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                16.spaceY,

                Text(
                  data.title ?? "-",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                16.spaceY,

                if (data.location != null &&
                    (data.location?.isNotEmpty ?? false) &&
                    data.location != "-")
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      spacing: 12,
                      children: [
                        Icon(
                          IconsaxPlusBold.location,
                          color: Colors.black54,
                          size: 18,
                        ),
                        Expanded(
                          child: Text(
                            data.location ?? "-",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Text(
                  data.createdAt ?? "-",
                  style: robotoRegular.copyWith(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                16.spaceY,

                fh.Html(
                  data: data.desc,
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
                    ),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
