import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/event/persentation/provider/detail_event_notifier.dart';

class EventDetailPage extends StatefulWidget {
  final int id;
  const EventDetailPage({
    required this.id,
    super.key}
  );

  @override
  State<EventDetailPage> createState() => EventDetailPageState();
}

class EventDetailPageState extends State<EventDetailPage> {

  late DetailEventNotifier detailEventNotifier;

  Future<void> getData() async {
    if(!mounted) return;
      detailEventNotifier.find(id: widget.id);
  }

  @override 
  void initState() {
    super.initState();

    detailEventNotifier = context.read<DetailEventNotifier>();

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16.0, right: 32, bottom: 10),
            child: const Text('Perjalanan Saya',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          )
        ),
      ),
      body: Consumer<DetailEventNotifier>(
        builder: (BuildContext context, DetailEventNotifier notifier, Widget? child) {
          if(notifier.state == ProviderState.loading) {
            return const Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFFFE1717)),
                ),
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(notifier.entity.title.toString(),
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: const []
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notifier.entity.startDay.toString(),
                              style: robotoRegular.copyWith(
                                color: const Color(0xffBBBBBB),
                                fontWeight: FontWeight.w600,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                            Text(notifier.entity.startDate.toString(),
                              style: robotoRegular.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                            Text(notifier.entity.continent.toString(),
                              style: robotoRegular.copyWith(
                                color: const Color(0xff939393),
                                fontWeight: FontWeight.w600,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ],
                        ),
                        Image.asset('assets/images/airplane.png'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              notifier.entity.endDay.toString(),
                              style: robotoRegular.copyWith(
                                color: const Color(0xffBBBBBB),
                                fontWeight: FontWeight.w600,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                            Text(notifier.entity.endDate.toString(),
                              style: robotoRegular.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                            Text(notifier.entity.state.toString(),
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
              const SizedBox(
                height: 12,
              ),
              Text(notifier.entity.description.toString(),
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorResources.black
                ),
              )
            ],
          );
        }
      ),
    );
  }
}
