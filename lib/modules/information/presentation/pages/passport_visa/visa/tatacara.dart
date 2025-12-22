import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

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
            padding: .fromLTRB(16, 16, 32, 10),
            child: Text(
              'Tatacara Pembuatan Visa',
              style: TextStyle(fontWeight: .bold, fontSize: 24),
            ),
          ),
        ),
      ),
      body: Consumer<InformationProvider>(
        builder: (context, n, child) {
          if (n.isGetVisa(.loading)) {
            return const Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (n.isGetVisa(.error)) {
            return Center(
              child: Text(
                n.errorMessage ?? "-",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            );
          }
          return ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: .symmetric(horizontal: 16.0, vertical: 12.0),
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
