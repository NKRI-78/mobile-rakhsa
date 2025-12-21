import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/core/enums/request_state.dart';

import 'package:rakhsa/modules/information/presentation/provider/information_provider.dart';

class PassportInfoPage extends StatefulWidget {
  final String stateId;

  const PassportInfoPage({required this.stateId, super.key});

  @override
  State<PassportInfoPage> createState() => PassportInfoPageState();
}

class PassportInfoPageState extends State<PassportInfoPage> {
  late InformationProvider informationProvider;

  Future<void> getData() async {
    if (!mounted) return;
    informationProvider.getPassportInfo(widget.stateId.toString());
  }

  @override
  void initState() {
    super.initState();

    informationProvider = context.read<InformationProvider>();

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
              'Passport Baru',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),
      ),
      body: Consumer<InformationProvider>(
        builder: (context, n, child) {
          if (n.isGetPassport(RequestState.loading)) {
            return const Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (n.isGetPassport(RequestState.error)) {
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
                n.passportData ?? "-",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          );
        },
      ),
    );
  }
}
