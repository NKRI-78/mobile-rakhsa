import 'package:flutter/material.dart';

import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

class PanduanHukumPage extends StatefulWidget {
  const PanduanHukumPage({super.key});

  @override
  State<PanduanHukumPage> createState() => PanduanHukumPageState();
}

class PanduanHukumPageState extends State<PanduanHukumPage> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text("Panduan"),
            ),
          ),
          SliverPadding(
            padding: EdgeInsetsGeometry.all(20),
            sliver: SliverToBoxAdapter(
              child: Text.rich(
                TextSpan(
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: ColorResources.black,
                  ),
                  children: [
                    TextSpan(
                      text: '1. Persiapan Dokumen Penting\n',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Paspor dan Visa: Pastikan paspor memiliki masa berlaku yang cukup, biasanya minimal 6 bulan sebelum tanggal kedaluwarsa. Sesuaikan juga dengan persyaratan visa di negara tujuan.\n'
                          'Dokumen Identitas Lain: Salin dokumen penting (KTP, KK, SIM) sebagai cadangan jika diperlukan.\n'
                          'Surat Keterangan bagi Pekerja Migran: Jika Anda bekerja, pastikan memiliki surat keterangan kerja atau kontrak yang sah untuk menghindari masalah hukum.\n\n',
                    ),

                    TextSpan(
                      text: '2. Informasi Kontak KBRI/Konsulat\n',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Catat alamat, nomor telepon, dan informasi kontak lainnya dari KBRI atau Konsulat RI di negara tujuan Anda. Informasi ini penting untuk keperluan darurat, seperti kehilangan paspor, mengalami kecelakaan, atau situasi hukum lainnya.\n\n',
                    ),

                    TextSpan(
                      text:
                          '3. Pengetahuan tentang Hukum dan Aturan Setempat\n',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Hukum Lokal: Pahami hukum setempat, terutama yang berbeda dengan hukum di Indonesia. Hal ini meliputi peraturan tentang obat-obatan, alkohol, adat istiadat, dan aturan berpakaian.\n'
                          'Peraturan Imigrasi dan Pekerjaan: Jangan bekerja di luar negeri tanpa izin resmi, karena hal ini bisa menyebabkan deportasi atau masalah hukum lainnya.\n\n',
                    ),

                    TextSpan(
                      text: '4. Kepatuhan terhadap Protokol Kesehatan\n',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Vaksinasi: Pastikan mematuhi persyaratan vaksinasi atau pemeriksaan kesehatan lainnya di negara tujuan, termasuk persyaratan COVID-19.\n'
                          'Asuransi Kesehatan: Disarankan untuk memiliki asuransi kesehatan internasional yang dapat menanggung biaya pengobatan di luar negeri.\n\n',
                    ),

                    TextSpan(
                      text: '5. Penggunaan Mata Uang dan Transaksi Keuangan\n',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Pembatasan Uang Tunai: Beberapa negara memiliki batasan jumlah uang tunai yang dapat dibawa masuk. Pastikan Anda mengetahui dan mematuhi aturan ini.\n'
                          'Kartu Kredit/Debit Internasional: Bawa kartu yang bisa digunakan untuk transaksi internasional dan simpan kontak layanan pelanggan bank untuk mengantisipasi masalah.\n\n',
                    ),

                    TextSpan(
                      text: '6. Menghindari Tindakan yang Melanggar Hukum\n',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Peredaran Narkotika: Banyak negara memiliki hukuman berat untuk pelanggaran terkait narkotika. Hindari membawa, menggunakan, atau terlibat dalam perdagangan narkoba.\n'
                          'Perilaku yang Mengganggu Ketertiban Umum: Pahami adat setempat agar terhindar dari perilaku yang dianggap menyinggung atau melanggar norma lokal, seperti kebisingan, merokok di area terlarang, atau berperilaku tidak sopan.\n\n',
                    ),

                    TextSpan(
                      text:
                          '7. Perlindungan Terhadap Eksploitasi atau Penipuan\n',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Pekerja Migran: WNI yang bekerja di luar negeri disarankan untuk selalu berkomunikasi dengan KBRI atau Konsulat RI guna melaporkan keberadaan dan status kerja mereka.\n'
                          'Penipuan: Hindari ajakan investasi atau bisnis yang mencurigakan, terutama yang melibatkan pihak asing yang belum dikenal.\n\n',
                    ),

                    TextSpan(
                      text:
                          '8. Langkah Darurat jika Menghadapi Masalah Hukum\n',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Lapor ke KBRI: Jika menghadapi masalah hukum seperti penahanan, kehilangan paspor, atau menjadi korban tindak kriminal, segera laporkan ke KBRI atau Konsulat RI untuk mendapat bantuan.\n'
                          'Konsultasi dengan Pengacara: Dalam beberapa kasus, KBRI dapat membantu mengarahkan Anda ke pengacara atau penasihat hukum yang bisa membantu.\n\n',
                    ),

                    TextSpan(
                      text: '9. Menghindari Masalah Keimigrasian\n',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Lapor Diri: Beberapa negara meminta WNI yang tinggal dalam jangka waktu lama untuk melapor diri ke KBRI atau Konsulat RI. Ini juga membantu KBRI menghubungi Anda dalam situasi darurat.\n'
                          'Perpanjangan Visa atau Izin Tinggal: Jangan lupa untuk memperpanjang visa atau izin tinggal jika diperlukan agar terhindar dari sanksi keimigrasian.\n\n',
                    ),

                    TextSpan(
                      text: '10. Pentingnya Asuransi Perjalanan\n',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Asuransi Kesehatan dan Perjalanan: Memiliki asuransi perjalanan yang mencakup masalah kesehatan, kecelakaan, dan penggantian biaya perjalanan jika terjadi pembatalan atau penundaan adalah langkah penting dalam perlindungan diri.\n'
                          'Dengan mengikuti panduan-panduan ini, WNI diharapkan bisa merasa lebih aman dan terlindungi saat bepergian ke luar negeri, serta mengetahui langkah-langkah yang harus diambil apabila menghadapi masalah atau situasi darurat.\n',
                    ),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
