import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:url_launcher/url_launcher.dart';

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
          height: context.getScreenHeight(0.7),
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
<p>Selamat datang di Marlinda. Dengan menggunakan aplikasi ini, Anda setuju untuk terikat dengan Syarat dan Ketentuan berikut. Harap baca dengan saksama sebelum menggunakan layanan.</p>

<p><strong>1. Definisi</strong></p>
<ul>
  <li><strong>Aplikasi</strong>: Marlinda, platform komunikasi bagi WNI ke luar negeri.</li>
  <li><strong>Pengguna</strong>: Individu yang mengakses dan menggunakan aplikasi.</li>
  <li><strong>Layanan</strong>: Seluruh fitur komunikasi, informasi, dan bantuan yang tersedia dalam aplikasi.</li>
</ul>

<p class="mt"><strong>2. Penerimaan Syarat</strong><br/>
Dengan mengakses atau menggunakan aplikasi, pengguna dianggap telah membaca, memahami, dan menyetujui seluruh Syarat dan Ketentuan ini.</p>

<p><strong>3. Penggunaan Layanan</strong></p>
<ul>
  <li>Pengguna wajib menggunakan aplikasi sesuai hukum yang berlaku.</li>
  <li>Pengguna tidak diperkenankan menggunakan aplikasi untuk tindakan yang melanggar hukum, menipu, mengganggu, atau merusak pihak lain.</li>
  <li>Pengguna bertanggung jawab atas keamanan akun dan aktivitas dalam akunnya.</li>
</ul>

<p><strong>4. Akun Pengguna</strong></p>
<ul>
  <li>Pengguna harus menyediakan informasi yang akurat dan benar saat membuat akun.</li>
  <li>Pengguna bertanggung jawab menjaga kerahasiaan informasi login.</li>
  <li>Marlinda berhak menangguhkan atau menghapus akun yang melanggar aturan.</li>
</ul>

<p><strong>5. Data dan Privasi</strong></p>
<ul>
  <li>Kami mengumpulkan data sesuai kebutuhan layanan, termasuk informasi dasar profil dan data penggunaan.</li>
  <li>Data digunakan untuk meningkatkan layanan, analisis internal, dan komunikasi penting.</li>
  <li>Privasi pengguna dilindungi sesuai Kebijakan Privasi yang berlaku.</li>
</ul>

<p><strong>6. Konten Pengguna</strong></p>
<ul>
  <li>Pengguna bertanggung jawab atas konten yang dikirimkan atau dibagikan.</li>
  <li>Pengguna dilarang mengunggah konten ilegal, berbahaya, atau melanggar hak kekayaan intelektual.</li>
  <li>Marlinda berhak menghapus konten yang dianggap melanggar ketentuan.</li>
</ul>

<p><strong>7. Hak Kekayaan Intelektual</strong></p>
<ul>
  <li>Semua logo, desain, teks, software, dan elemen aplikasi adalah milik Marlinda.</li>
  <li>Dilarang mendistribusikan, memodifikasi, atau menggunakan materi tersebut tanpa izin tertulis.</li>
</ul>

<p class="mt"><strong>8. Pembatasan Tanggung Jawab</strong><br/>
Marlinda tidak bertanggung jawab atas kehilangan data, kerusakan, atau kerugian yang timbul akibat penggunaan aplikasi yang tidak sesuai dengan syarat dan ketentuan berlaku.</p>

<p><strong>9. Perubahan Layanan dan Syarat</strong></p>
<ul>
  <li>Marlinda dapat memperbarui fitur, layanan, atau syarat ini kapan saja.</li>
  <li>Perubahan akan diumumkan dalam aplikasi. Penggunaan berkelanjutan berarti setuju pada perubahan tersebut.</li>
</ul>

<p class="mt"><strong>10. Pengakhiran Layanan</strong></p>
<ul>
  <li>Pengguna dapat berhenti menggunakan aplikasi kapan saja.</li>
  <li>Marlinda dapat membatasi akses jika terdapat pelanggaran syarat.</li>
</ul>

<p class="mt"><strong>11. Hukum yang Berlaku</strong><br/>
Syarat ini diatur oleh hukum Republik Indonesia.</p>

<p class="mt"><strong>12. Kontak</strong><br/>
Untuk pertanyaan atau dukungan, hubungi: <a href="tel:081119911911">081119911911</a>. </p>

<p><strong>Dengan menggunakan Marlinda, Anda menyetujui seluruh ketentuan di atas.</strong></p>
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
                        "p.mt": Style(
                          padding: HtmlPaddings.only(top: 6),
                          fontSize: FontSize(12),
                        ),
                      },
                      onLinkTap: (url, attributes, element) async {
                        if (url == null) return;
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
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
