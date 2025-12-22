import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';

import 'package:flutter_html/flutter_html.dart' as fh;
import 'package:rakhsa/core/constants/colors.dart';

import 'package:rakhsa/core/extensions/extensions.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/detail_news_notifier.dart';

class EwsDetailPageParams {
  final int id;
  final String type;

  EwsDetailPageParams({required this.id, required this.type});
}

class EwsDetailPage extends StatefulWidget {
  final int id;
  final String type;

  const EwsDetailPage({required this.id, required this.type, super.key});

  @override
  State<EwsDetailPage> createState() => EwsDetailPageState();
}

class EwsDetailPageState extends State<EwsDetailPage> {
  late DetailNewsNotifier _notifier;

  @override
  void initState() {
    super.initState();

    _notifier = context.read<DetailNewsNotifier>();

    Future.microtask(() => getData());
  }

  Future<void> getData() async {
    if (!mounted) return;
    await _notifier.detailNews(id: widget.id);
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
          if (notifier.state != .loaded) {
            return Center(
              child: Column(
                spacing: 16,
                mainAxisSize: .min,
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
              padding: .fromLTRB(16, 16, 16, context.bottom + 16),
              children: [
                ClipRRect(
                  borderRadius: .circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: data.img ?? "",
                      fit: .cover,
                    ),
                  ),
                ),

                16.spaceY,

                Text(
                  data.title ?? "-",
                  style: TextStyle(fontSize: 18, fontWeight: .bold),
                ),

                16.spaceY,

                if (data.location != null &&
                    (data.location?.isNotEmpty ?? false) &&
                    data.location != "-")
                  Padding(
                    padding: .only(bottom: 16),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                16.spaceY,

                fh.Html(
                  data: data.desc,
                  style: {
                    'body': fh.Style(
                      margin: fh.Margins.zero,
                      fontSize: fh.FontSize(12),
                    ),
                    'p': fh.Style(
                      margin: fh.Margins.zero,
                      fontSize: fh.FontSize(12),
                    ),
                    'span': fh.Style(
                      margin: fh.Margins.zero,
                      fontSize: fh.FontSize(12),
                    ),
                    'div': fh.Style(
                      margin: fh.Margins.zero,
                      fontSize: fh.FontSize(12),
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
