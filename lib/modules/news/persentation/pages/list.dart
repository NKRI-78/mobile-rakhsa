import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/core/enums/provider_state.dart';
import 'package:rakhsa/router/route_trees.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/modules/news/persentation/pages/detail.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => NewsListPageState();
}

class NewsListPageState extends State<NewsListPage> {
  late DashboardNotifier dashboardNotifier;

  Future<void> getData() async {
    if (!mounted) return;
    await dashboardNotifier.getNews(lat: 0.0, lng: 0.0);
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
        leading: CupertinoNavigationBarBackButton(onPressed: context.pop),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, right: 32.0, bottom: 10.0),
            child: Text(
              'Berita Terkini Seputar Indonesia',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),
      ),
      body: Consumer<DashboardNotifier>(
        builder: (context, n, child) {
          if (n.state == ProviderState.loading) {
            return const Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (n.state == ProviderState.empty) {
            return Center(
              child: Text(
                "Belum ada berita",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            );
          }
          if (n.state == ProviderState.error) {
            return Center(
              child: Text(
                n.message,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
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
                    NewsDetailRoute(
                      NewsDetailPageParams(
                        id: n.news[0].id,
                        type: n.news[0].type,
                      ),
                    ).go(context);
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    height: MediaQuery.sizeOf(context).width * .6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CachedNetworkImage(
                            fit: BoxFit.fitWidth,
                            imageUrl: n.news[0].img.toString(),
                            placeholder: (BuildContext context, String url) {
                              return Image.asset(
                                'assets/images/user-placeholder.webp',
                              );
                            },
                            errorWidget:
                                (
                                  BuildContext context,
                                  String url,
                                  Object error,
                                ) {
                                  return Image.asset(
                                    'assets/images/user-placeholder.webp',
                                  );
                                },
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
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8.0,
                          left: 16.0,
                          right: 16.0,
                          child: Text(
                            n.news[0].title.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18.0),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: n.news.length,
                  itemBuilder: (BuildContext context, int i) {
                    if (i == 0) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () {
                          NewsDetailRoute(
                            NewsDetailPageParams(
                              id: n.news[i].id,
                              type: n.news[i].type,
                            ),
                          ).go(context);
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
                                  fit: BoxFit.cover,
                                  imageUrl: n.news[i].img.toString(),
                                  placeholder:
                                      (BuildContext context, String url) {
                                        return Image.asset(
                                          'assets/images/user-placeholder.webp',
                                        );
                                      },
                                  errorWidget:
                                      (
                                        BuildContext context,
                                        String url,
                                        Object error,
                                      ) {
                                        return Image.asset(
                                          'assets/images/user-placeholder.webp',
                                        );
                                      },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        n.news[i].title,
                                        maxLines: 3,
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        n.news[i].createdAt,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
