import 'package:flutter/material.dart';
import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/common/utils/color_resources.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/event/data/models/list.dart';

import 'package:rakhsa/features/event/persentation/pages/create.dart';
import 'package:rakhsa/features/event/persentation/pages/detail.dart';
import 'package:rakhsa/features/event/persentation/pages/edit.dart';
import 'package:rakhsa/features/event/persentation/provider/list_event_notifier.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => EventListPageState();
}

class EventListPageState extends State<EventListPage> {

  late ListEventNotifier listEventNotifier; 

  Future<void> getData() async {
    if(!mounted) return;
      listEventNotifier.list();
  }

  @override 
  void initState() {
    super.initState();

    listEventNotifier = context.read<ListEventNotifier>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        leading: const SizedBox(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 32, bottom: 10),
            child: Text('Tentukan Rencana Perjalanan mu di Sini',
              style: robotoRegular.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: Dimensions.fontSizeOverLarge,
              ),
            ),
          )
        ),
      ),
      body: Consumer<ListEventNotifier>(
        builder: (BuildContext context, ListEventNotifier notifier, Widget? child) {
          if(notifier.state == ProviderState.loading) {
            return const Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFFFE1717)),
                ),
              )
            );
          }
          if(notifier.state == ProviderState.empty) {
            return Text(
              'Belum ada Rencana yang di Buat',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700
              ),
            );
          }
          if(notifier.state == ProviderState.error) {
            return Center(
              child: Text(notifier.message,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorResources.black
                ),
              ),
            );
          }
          return EventListView(
            events: notifier.entity,
            getData: getData,
          );
        },
      )
    );
  }
}

class EventListView extends StatelessWidget {
  final List<EventData> events;
  final Function getData;

  const EventListView({
    required this.events,
    required this.getData,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () {
        return Future.sync(() {
          getData();
        });
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
      
          SliverToBoxAdapter(
            child: EventListData(
              events: events,
              getData: getData,
            ),
          ),
      
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(
                  height: 26,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const EventCreatePage()
                    )).then((val) { 
                      if(val != "") {
                        getData();
                      }
                    });
                  },
                  
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                      8,
                    )),
                    backgroundColor: const Color(0xffFE1717),
                  ),
                  label: Text('Rencana',
                    style: robotoRegular.copyWith(
                      color: ColorResources.white
                    ),
                  ),
                  icon: const Icon(
                    Icons.add,
                    color: ColorResources.white,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class EventListData extends StatelessWidget {
  final List<EventData> events;
  final Function getData;

  const EventListData({
    required this.events,
    required this.getData,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16),
      shrinkWrap: true,
      itemCount: events.length,
      itemBuilder: (BuildContext context, int i) {
        return Container(
          margin: const EdgeInsets.only(top: 10.0),
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return EventDetailPage(
                  id: events[i].id,
                );
              }));
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(2, 2),
                    color: Colors.black.withOpacity(.3),
                    blurRadius: 10,
                    spreadRadius: 0,
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      
                      Text(events[i].title,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Row(
                        children: [

                          Material(
                            child: InkWell(
                              onTap: () {
                                GeneralModal.deleteEvent(
                                  id: events[i].id,
                                  getData: getData
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.delete,
                                  color: ColorResources.error,
                                  size: 15.0,
                                )
                              ),
                            ),
                          ),

                          const SizedBox(width: 5.0),

                          Material(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return EventEditPage(id: events[i].id);
                                }));
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.edit,
                                  color: ColorResources.blue,
                                  size: 15.0,
                                ),
                              ),
                            ),
                          )

                        ],
                      ),

                    ],
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            events[i].startDay,
                            style: robotoRegular.copyWith(
                              color: const Color(0xffBBBBBB),
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            events[i].startDate,
                            style: robotoRegular.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                            ),
                          ),
                          Text(
                            events[i].continent,
                            style: robotoRegular.copyWith(
                              color: const Color(0xff939393),
                              fontWeight: FontWeight.w600,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      Image.asset('assets/images/airplane.png'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            events[i].endDay,
                            style: robotoRegular.copyWith(
                              color: const Color(0xffBBBBBB),
                              fontWeight: FontWeight.w600,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                          Text(events[i].endDate,
                            style: robotoRegular.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: Dimensions.fontSizeLarge,
                            )
                          ),  
                          Text(events[i].state,
                            style: robotoRegular.copyWith(
                              color: const Color(0xff939393),
                              fontWeight: FontWeight.w600,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}