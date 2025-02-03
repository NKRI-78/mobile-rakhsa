import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/color_resources.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/event/data/models/list.dart';
import 'package:rakhsa/features/event/persentation/pages/detail.dart';
import 'package:rakhsa/features/event/persentation/pages/edit.dart';
import 'package:rakhsa/features/event/persentation/provider/list_event_notifier.dart';

import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

import 'package:googleapis/calendar/v3.dart' as googleapi;

import 'package:http/http.dart' as http;

class GoogleAuthClient extends http.BaseClient {
  final String accessToken;
  final String idToken;

  GoogleAuthClient(this.accessToken, this.idToken);

 @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['Authorization'] = 'Bearer $accessToken';
    return await http.Client().send(request);
  }
}

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => EventListPageState();
}

class EventListPageState extends State<EventListPage> {

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      googleapi.CalendarApi.calendarScope
    ]
  ); 

  late ListEventNotifier listEventNotifier; 

  Future<void> initializeCalendarApi() async {
    try {
     
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception("Google Sign-In failed");
      } 

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

       final GoogleAuthClient authenticatedClient = GoogleAuthClient(
        googleAuth.accessToken.toString(),
        googleAuth.idToken.toString(),
      );

      final googleapi.CalendarApi calendarAPI = googleapi.CalendarApi(authenticatedClient);
   
      final googleapi.Events events = await calendarAPI.events.list('primary');

      events.items?.forEach((event) {
        String summary = event.summary.toString();
        String description = event.description.toString();
        DateTime startDatetime = event.start?.dateTime ?? DateTime.now();
        DateTime endDatetime = event.end?.dateTime ?? DateTime.now();

        listEventNotifier.appendToEventGoogleCalendar(
          summary: summary, 
          description: description,
          startDate: DateFormat.yMMMMEEEEd().format(startDatetime),
          endDate: DateFormat.yMMMMEEEEd().format(endDatetime)
        );
      });

      debugPrint("=== SUCCESFULLY SIGNED GOOGLE ===");
    } catch(e) {
      debugPrint("=== ERROR SIGNED GOOGLE: ${e.toString()} ===");
    }
  }

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
        leading: CupertinoNavigationBarBackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
            return Text('Belum ada Rencana yang di Buat',
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
      
          StorageHelper.getUserId() == null 
          ? SliverFillRemaining(
              child: Center(
                child: Text('Belum ada Rencana yang di Buat',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700
                  ),
                )
              ),
            )
          : SliverToBoxAdapter(
              child: EventListData(
                events: events,
                getData: getData,
              ),
            ),

            StorageHelper.getUserId() == null 
            ? const SliverToBoxAdapter()
            : SliverToBoxAdapter(
                child: Column(
                  children: [
                  const SizedBox(
                    height: 26,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, RoutesNavigation.itineraryCreate).then((val) {
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
            onTap: events[i].type == "google" 
            ? () {}
            : () {
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
                      
                      Expanded(
                        child: Text(events[i].title,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      events[i].type == "google" 
                      ? const SizedBox()
                      : Row(
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
                                })).then((val) {
                                  if(val != "") {
                                    getData();
                                  }
                                });
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
                      
                      events[i].type == "google" 
                      ? Image.asset('assets/images/google-calendar.png',
                          width: 90.0,
                          height: 90.0,
                        )
                      : Image.asset('assets/images/airplane.png'),

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