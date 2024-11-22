import 'package:flutter/material.dart';
import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/common/utils/color_resources.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/event/data/models/list.dart';

import 'package:rakhsa/features/event/persentation/pages/create.dart';
import 'package:rakhsa/features/event/persentation/provider/list_event_notifier.dart';

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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, right: 32, bottom: 10),
            child: Text('Tentukan Rencana Perjalanan mu di Sini',
              style: TextStyle(
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
            events: notifier.entity
          );
        },
      )
    );
  }
}

class EventListView extends StatelessWidget {
  final List<EventData> events;

  const EventListView({
    required this.events,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [

        // const SliverToBoxAdapter(
        //   child: EventListEmpty(),
        // ),

        SliverToBoxAdapter(
          child: EventListData(
            events: events
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
                  ));
                },
                
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                    8,
                  )),
                  backgroundColor: const Color(0xffFE1717),
                ),
                label: const Text('Rencana',
                  style: TextStyle(color: ColorResources.white),
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
    );
  }
}

class EventListData extends StatelessWidget {
  final List<EventData> events;

  const EventListData({
    required this.events,
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
        return InkWell(
          onTap: () {
            // Navigator.push(context,
            // MaterialPageRoute(builder: (_) => const EventDetailPage()));
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
                Text(events[i].title,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
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
                          style: const TextStyle(
                            color: Color(0xffBBBBBB),
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          events[i].startDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                          ),
                        ),
                        Text(
                          events[i].continent,
                          style: const TextStyle(
                            color: Color(0xff939393),
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
                          style: const TextStyle(
                            color: Color(0xffBBBBBB),
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          events[i].endDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                          ),
                        ),
                        Text(events[i].state,
                          style: const TextStyle(
                            color: Color(0xff939393),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class EventListEmpty extends StatelessWidget {
  const EventListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 32,
        ),
        Text(
          'Belum ada Rencana yang di Buat',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
