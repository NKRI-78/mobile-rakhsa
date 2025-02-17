import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/features/event/persentation/provider/event_notifier.dart';
import 'package:rakhsa/features/event/persentation/widget/itinerary_button.dart';
import 'package:rakhsa/features/event/persentation/widget/itinerary_list_tile.dart';

class AllEventPage extends StatelessWidget {
  const AllEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text('Semua Agenda'),
        titleTextStyle: robotoRegular.copyWith(
          fontSize: 20,
          color: whiteColor,
        ),
        leading: CupertinoNavigationBarBackButton(
          color: whiteColor,
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: Image.asset(
            AssetSource.loginOrnament,
            fit: BoxFit.cover,
          ),
        ),
      ),
      body: Consumer<EventNotifier>(
        builder: (context, notifier, child) {
          if (notifier.getEventState == ProviderState.loading) {
            return SizedBox(
              width: double.infinity,
              height: 200,
              child: Center(
                child: Text(
                  'Memuat agenda..',
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                    color: redColor,
                  ),
                ),
              ),
            );
          } else if (notifier.getEventState == ProviderState.error) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  notifier.errorMessageGetEvent!,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                    color: redColor,
                  ),
                ),
              ),
            );
          } else {
            if (notifier.eventList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Anda belum membuat Agenda',
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ItineraryButton(
                        label: 'Buat agenda disini', 
                        action: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return ListView.separated(
                itemCount: notifier.eventList.length,
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final event = notifier.eventList[index];
        
                  return ItineraryListTile(event);
                },
              );
            }
          }
        },
      ),
    );
  }
}