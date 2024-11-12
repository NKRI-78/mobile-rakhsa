import 'package:flutter/material.dart';
import 'package:rakhsa/features/pages/news/persentation/pages/detail.dart';

class NewsListPage extends StatelessWidget {
  const NewsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F7),
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
                'Berita Terkini Seputar Indonesia',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            height: MediaQuery.sizeOf(context).width * .6,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(9)),
            child: Stack(
              children: [
                Image.network(
                  'https://indikator.co.id/wp-content/uploads/2024/02/COVER-YT-RILIS-INDIKATOR-09-FEBRUARI-2024-1024x576.jpg',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(.3),
                        Colors.black,
                      ])),
                ),
                const Positioned(
                    bottom: 8,
                    left: 16,
                    right: 16,
                    child: Text(
                      'Survei Indikator: Banyak Pendukung PDIP Justru Pilih Bobby Nasution di Sumut',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ))
              ],
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          ...List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NewsDetailPage()));
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: double.infinity,
                        child: Image.network(
                          'https://i.ytimg.com/vi/4sZeLgimKw0/maxresdefault.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Alur Jual-Beli Rekening Penampungan Judol dari WNI Dikirim ke Kamboja',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12.46,
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              '7 menit yang lalu',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 7,
                              ),
                            )
                          ],
                        ),
                      ))
                    ],
                  ),
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}
