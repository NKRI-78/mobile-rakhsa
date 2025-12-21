import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/core/enums/request_state.dart';

import 'package:rakhsa/modules/information/presentation/provider/information_provider.dart';

class TataCaraPage extends StatefulWidget {
  final String stateId;

  const TataCaraPage({required this.stateId, super.key});

  @override
  State<TataCaraPage> createState() => TataCaraPageState();
}

class TataCaraPageState extends State<TataCaraPage> {
  late InformationProvider informationProvider;

  Future<void> getData() async {
    if (!mounted) return;
    informationProvider.getVisaInfo(widget.stateId);
  }

  @override
  void initState() {
    super.initState();

    informationProvider = context.read<InformationProvider>();

    Future.microtask(() => getData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        automaticallyImplyLeading: false,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.black,
          onPressed: context.pop,
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),
      ),
      body: Consumer<InformationProvider>(
        builder: (context, n, child) {
          if (n.isGetVisa(RequestState.loading)) {
            return const Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (n.isGetVisa(RequestState.error)) {
            return Center(
              child: Text(
                n.errorMessage ?? "-",
                style: TextStyle(fontSize: 14, color: Colors.black),
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
                n.visaData ?? "-",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          );
        },
      ),
    );
  }
}
