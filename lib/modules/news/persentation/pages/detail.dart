import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_html/flutter_html.dart' as fh;

import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/routes/routes_navigation.dart';

import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/detail_news_notifier.dart';

class NewsDetailPage extends StatefulWidget {
  final int id;
  final String type;

  const NewsDetailPage({required this.id, required this.type, super.key});

  @override
  State<NewsDetailPage> createState() => NewsDetailPageState();
}

class NewsDetailPageState extends State<NewsDetailPage> {
  late DetailNewsNotifier detailNewsNotifier;

  Future<void> getData() async {
    if (!mounted) return;
    await detailNewsNotifier.detailNews(id: widget.id);
  }

  @override
  void initState() {
    super.initState();

    detailNewsNotifier = context.read<DetailNewsNotifier>();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false,
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // if (didPop) return;
        // Navigator.pushReplacementNamed(context, RoutesNavigation.dashboard);
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF4F4F7),
        appBar: AppBar(
          backgroundColor: const Color(0xffF4F4F7),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () {
              // Navigator.pushReplacementNamed(
              //   context,
              //   RoutesNavigation.dashboard,
              // );
              context.pop();
            },
            color: ColorResources.black,
          ),
        ),
        body: Consumer<DetailNewsNotifier>(
          builder: (BuildContext context, DetailNewsNotifier notifier, Widget? child) {
            if (notifier.state == ProviderState.loading) {
              return const Center(
                child: SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (notifier.state == ProviderState.error) {
              return const SizedBox();
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  notifier.entity.title.toString(),
                  style: robotoRegular.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                SizedBox(
                  height: notifier.entity.location.toString().isNotEmpty
                      ? 12.0
                      : 0.0,
                ),
                Container(
                  clipBehavior: Clip.antiAlias,
                  height: MediaQuery.sizeOf(context).width * .6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  child: Image.network(
                    notifier.entity.img.toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: notifier.entity.location.toString().isNotEmpty
                      ? 18.0
                      : 0.0,
                ),
                Text(
                  notifier.entity.location.toString(),
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    fontWeight: FontWeight.bold,
                    color: ColorResources.black,
                  ),
                ),
                SizedBox(
                  height: notifier.entity.location.toString().isNotEmpty
                      ? 10.0
                      : 0.0,
                ),
                Text(
                  notifier.entity.createdAt.toString(),
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: ColorResources.grey,
                  ),
                ),
                const SizedBox(height: 15.0),
                fh.Html(
                  data: notifier.entity.desc.toString(),
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

                widget.type == "ews"
                    ? const SizedBox()
                    : const SizedBox(height: 18),
                widget.type == "ews"
                    ? const SizedBox()
                    : context.watch<DashboardNotifier>().state ==
                          ProviderState.loading
                    ? const SizedBox()
                    : context.watch<DashboardNotifier>().state ==
                          ProviderState.empty
                    ? const SizedBox()
                    : const Text(
                        '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                widget.type == "ews"
                    ? const SizedBox()
                    : const SizedBox(height: 18),
                widget.type == "ews"
                    ? const SizedBox()
                    : Consumer<DashboardNotifier>(
                        builder:
                            (
                              BuildContext context,
                              DashboardNotifier notifier,
                              Widget? child,
                            ) {
                              if (notifier.state == ProviderState.loading) {
                                return const Center(
                                  child: SizedBox(
                                    width: 16.0,
                                    height: 16.0,
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (notifier.state == ProviderState.empty) {
                                return const SizedBox();
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: notifier.news.length,
                                itemBuilder: (BuildContext context, int i) {
                                  if (notifier.news[i].id == widget.id) {
                                    return const SizedBox();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          RoutesNavigation.newsDetail,
                                          (route) => route.isFirst,
                                          arguments: {
                                            'id': notifier.news[i].id,
                                            'type': widget.type,
                                          },
                                        );
                                      },
                                      child: Container(
                                        clipBehavior: Clip.antiAlias,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              height: double.infinity,
                                              child: CachedNetworkImage(
                                                fit: BoxFit.fitWidth,
                                                imageUrl: notifier.news[i].img
                                                    .toString(),
                                                placeholder:
                                                    (
                                                      BuildContext context,
                                                      String url,
                                                    ) {
                                                      return Image.asset(
                                                        'assets/images/default.jpeg',
                                                      );
                                                    },
                                                errorWidget:
                                                    (
                                                      BuildContext context,
                                                      String url,
                                                      Object error,
                                                    ) {
                                                      return Image.asset(
                                                        'assets/images/default.jpeg',
                                                      );
                                                    },
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      notifier.news[i].title
                                                          .toString(),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: robotoRegular
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: Dimensions
                                                                .fontSizeDefault,
                                                          ),
                                                    ),

                                                    const SizedBox(height: 6.0),

                                                    fh.Html(
                                                      data: notifier
                                                          .news[i]
                                                          .desc
                                                          .toString(),
                                                      style: {
                                                        'body': fh.Style(
                                                          maxLines: 1,
                                                          margin:
                                                              fh.Margins.zero,
                                                          fontSize: fh.FontSize(
                                                            Dimensions
                                                                .fontSizeSmall,
                                                          ),
                                                        ),
                                                        'p': fh.Style(
                                                          maxLines: 1,
                                                          margin:
                                                              fh.Margins.zero,
                                                          fontSize: fh.FontSize(
                                                            Dimensions
                                                                .fontSizeSmall,
                                                          ),
                                                        ),
                                                        'span': fh.Style(
                                                          maxLines: 1,
                                                          fontSize: fh.FontSize(
                                                            Dimensions
                                                                .fontSizeSmall,
                                                          ),
                                                        ),
                                                        'div': fh.Style(
                                                          maxLines: 1,
                                                          fontSize: fh.FontSize(
                                                            Dimensions
                                                                .fontSizeSmall,
                                                          ),
                                                        ),
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
