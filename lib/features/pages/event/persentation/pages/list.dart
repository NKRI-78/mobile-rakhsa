import 'package:flutter/material.dart';
import 'package:rakhsa/features/pages/event/persentation/pages/create.dart';
import 'package:rakhsa/features/pages/event/persentation/pages/detail.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        leading: const Icon(
          Icons.arrow_back_ios_new,
          size: 30,
        ),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Padding(
              padding: EdgeInsets.only(left: 16.0, right: 32, bottom: 10),
              child: Text(
                'Tentukan Rencana Perjalanan mu di Sini',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            )),
      ),
      body: const EventListView(),
    );
  }
}

class EventListView extends StatelessWidget {
  const EventListView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // const SliverToBoxAdapter(
        //   child: EventListEmpty(),
        // ),

        const SliverToBoxAdapter(
          child: EventListData(),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(
                height: 26,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EventCreatePage()));
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                    8,
                  )),
                  backgroundColor: const Color(0xffFE1717),
                  iconColor: Colors.white,
                ),
                label: const Text(
                  'Rencana',
                  style: TextStyle(color: Colors.white),
                ),
                icon: const Icon(
                  Icons.add,
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
  const EventListData({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16),
      shrinkWrap: true,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EventDetailPage()));
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
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Liburan Amerika 2 Minggu',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jumat',
                          style: TextStyle(
                            color: Color(0xffBBBBBB),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '9 Feb 2025',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          'Amerika',
                          style: TextStyle(
                            color: Color(0xff939393),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Image.asset('assets/images/airplane.png'),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Jumat',
                          style: TextStyle(
                            color: Color(0xffBBBBBB),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '23 Feb 2025',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          'Indonesia',
                          style: TextStyle(
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
        )
      ],
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
