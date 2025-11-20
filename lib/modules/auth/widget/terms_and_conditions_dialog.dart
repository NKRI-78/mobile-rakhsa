import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/service/storage/storage.dart';

class TermsAndConditionsDialog extends StatefulWidget {
  const TermsAndConditionsDialog._(this.canPop);

  final bool canPop;

  static bool get hasLaunchBefore {
    return StorageHelper.sharedPreferences.getBool(
          "terms_and_conditions_cache_key",
        ) ??
        false;
  }

  static Future<bool?> launch(BuildContext c, [bool canPop = true]) {
    return showGeneralDialog<bool?>(
      context: c,
      barrierLabel: "",
      barrierDismissible: canPop,
      transitionDuration: Duration(milliseconds: 250),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        final scale = Tween<double>(begin: 0.2, end: 1.0).evaluate(curved);
        final opacity = Tween<double>(begin: 0.0, end: 1.0).evaluate(curved);
        return FadeTransition(
          opacity: AlwaysStoppedAnimation(opacity),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      pageBuilder: (_, _, _) => TermsAndConditionsDialog._(canPop),
    );
  }

  @override
  State<TermsAndConditionsDialog> createState() =>
      _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {
  bool agree = false;

  void _toggleAgree(bool? isAgree) {
    setState(() => agree = (isAgree ?? false));
  }

  void _completeDialog() async {
    await StorageHelper.sharedPreferences.setBool(
      "terms_and_conditions_cache_key",
      true,
    );
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canPop,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          height: context.mediaQuery.size.height * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Syarat dan Ketentuan",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),

              16.spaceY,

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Html(
                      data: """
                        <p><strong>Dengan menggunakan Aplikasi MARLINDA, Anda setuju pada S&amp;K berikut.</strong></p>
                        
                        <p><strong>1. Tujuan Layanan</strong><br/>
                        Aplikasi ini adalah Tombol Darurat (Panic Button) untuk Warga Negara Indonesia (WNI) di luar negeri, memfasilitasi koordinasi bantuan darurat langsung dengan KBRI/KJRI setempat.</p>
                        
                        <p><strong>2. Persyaratan Utama Penggunaan (Wajib)</strong></p>
                        <ul>
                          <li><strong>WNI</strong>: Layanan hanya untuk WNI.</li>
                          <li><strong>Roaming Telkomsel</strong>: Aplikasi hanya berfungsi jika Anda mengaktifkan paket roaming internasional Telkomsel. Tanpa paket aktif, layanan darurat akan gagal.</li>
                          <li><strong>GPS Aktif</strong>: Anda wajib mengaktifkan Layanan Lokasi (GPS) agar KBRI dapat menemukan lokasi Anda secara akurat.</li>
                        </ul>
                        
                        <p><strong>3. Prosedur Darurat</strong></p>
                        <ul>
                          <li><strong>Aktivasi</strong>: Menekan Panic Button akan otomatis mengirimkan lokasi Anda ke KBRI/KJRI dan memulai Perekaman Insiden (audio/video).</li>
                          <li><strong>Respon KBRI</strong>: KBRI/KJRI akan merespon sesuai diskresi dan prosedur internal mereka. Kami hanya bertindak sebagai fasilitator komunikasi.</li>
                        </ul>
                        
                        <p><strong>4. Batasan Tanggung Jawab</strong></p>
                        <ul>
                          <li>Kami tidak bertanggung jawab atas kegagalan layanan yang disebabkan oleh:
                            <ul>
                              <li>Gangguan sinyal, jaringan, atau ketiadaan paket roaming Telkomsel yang aktif.</li>
                              <li>Ketidakakuratan GPS.</li>
                              <li>Keterlambatan respons yang disebabkan oleh faktor eksternal (lalu lintas, keamanan setempat, dll.).</li>
                            </ul>
                          </li>
                          <li>Layanan dan waktu respon KBRI/KJRI tunduk pada kebijakan mereka dan kondisi negara setempat.</li>
                        </ul>
                        
                        <p><strong>5. Larangan Penyalahgunaan</strong></p>
                        <ul>
                          <li>Gunakan Panic Button hanya dalam situasi darurat yang sesungguhnya.</li>
                          <li>Penyalahgunaan (termasuk false alarm / lelucon) dapat menyebabkan penangguhan akun dan/atau tuntutan ganti rugi atas biaya pengerahan sumber daya yang tidak perlu.</li>
                        </ul>
                        
                        <p><strong>6. Data Pribadi</strong><br/>
                        Saat tombol ditekan, data Identitas, Lokasi Real-Time, dan Rekaman Insiden akan dikumpulkan dan dibagikan kepada KBRI/KJRI serta otoritas darurat setempat untuk tujuan bantuan.</p>
                        
                        """,
                      style: {
                        "p": Style(fontSize: FontSize(12)),
                        "ul": Style(
                          fontSize: FontSize(12),
                          padding: HtmlPaddings.only(left: 16),
                          margin: Margins.only(top: 4, bottom: 8),
                        ),
                        "ul ul": Style(
                          fontSize: FontSize(12),
                          padding: HtmlPaddings.only(left: 14),
                          margin: Margins.symmetric(vertical: 2),
                        ),
                        "li": Style(
                          fontSize: FontSize(12),
                          margin: Margins.only(bottom: 4),
                        ),
                      },
                    ),
                  ),
                ),
              ),

              10.spaceY,

              CheckboxListTile(
                value: agree,
                onChanged: _toggleAgree,
                activeColor: primaryColor,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -3, vertical: -3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(4),
                ),
                subtitle: Text(
                  "Saya telah membaca dan menyetujui Syarat dan Ketentuan MARLINDA di atas.",
                  style: TextStyle(fontSize: 11.3, fontWeight: FontWeight.w500),
                ),
              ),

              10.spaceY,

              FilledButton(
                onPressed: agree ? _completeDialog : null,
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),
                  textStyle: TextStyle(fontWeight: FontWeight.w600),
                ),
                child: Text("Lanjutkan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
