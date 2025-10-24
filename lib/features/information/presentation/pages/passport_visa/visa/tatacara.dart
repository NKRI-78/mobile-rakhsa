import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/misc/helpers/enum.dart';

import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/features/information/presentation/provider/visa_notifier.dart';

class TataCaraPage extends StatefulWidget {
  final String stateId;

  const TataCaraPage({required this.stateId, super.key});

  @override
  State<TataCaraPage> createState() => TataCaraPageState();
}

class TataCaraPageState extends State<TataCaraPage> {
  late VisaNotifier visaNotifier;

  Future<void> getData() async {
    if (!mounted) return;
    visaNotifier.infoVisa(stateId: widget.stateId);
  }

  @override
  void initState() {
    super.initState();

    visaNotifier = context.read<VisaNotifier>();

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
        automaticallyImplyLeading: false,
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 32,
              bottom: 10,
            ),
            child: Text(
              'Tatacara Pembuatan Visa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Dimensions.fontSizeOverLarge,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<VisaNotifier>(
        builder: (BuildContext context, VisaNotifier notifier, Widget? child) {
          if (visaNotifier.state == ProviderState.loading) {
            return const Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (visaNotifier.state == ProviderState.error) {
            return Center(
              child: Text(
                visaNotifier.message,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorResources.black,
                ),
              ),
            );
          }
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              top: 12.0,
              bottom: 12.0,
              left: 16.0,
              right: 16.0,
            ),
            children: [
              Text(
                visaNotifier.entity.data?.content.toString() ?? "-",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorResources.black,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
