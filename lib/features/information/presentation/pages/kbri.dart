import 'package:flutter/material.dart';

class KbbriPage extends StatefulWidget {
  const KbbriPage({super.key});

  @override
  State<KbbriPage> createState() => KbbriPageState();
}

class KbbriPageState extends State<KbbriPage> {

  @override
  void initState() {
    super.initState();
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [

        SliverAppBar(),

        

      ],
    );
  }
}