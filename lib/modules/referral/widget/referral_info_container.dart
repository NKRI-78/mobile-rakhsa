import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/repositories/referral/model/referral.dart';
import 'package:rakhsa/widgets/overlays/status_bar_style.dart';

class ReferralInfoContainer extends StatelessWidget {
  const ReferralInfoContainer({super.key, this.package});

  final ReferralPackage? package;

  @override
  Widget build(BuildContext context) {
    final namaPaket = package?.packageKeyword ?? "-";

    final now = DateTime.now();

    final startAt = (package?.startAt ?? now).format("dd MMMM yyyy");

    final end = package?.endAt ?? now;
    final endAt = end.format("dd MMMM yyyy");

    final diff = end.difference(now);
    final sisaMasaAktif = (diff.isNegative ? Duration.zero : diff).inDays;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 0.7),
      ),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfo(
            context,
            "Nama Paket",
            namaPaket,
            "Nama paket roaming yang aktif untuk saat ini.",
          ),
          Divider(),
          _buildInfo(
            context,
            "Status",
            "Aktif",
            "Status aktivasi paket roaming ditentukan oleh sisa masa aktif. Jika masa aktif paket roaming telah berakhir, aplikasi akan otomatis melakukan logout. Untuk dapat kembali menggunakan Marlinda, Anda perlu membeli paket roaming kembali dan login menggunakan akun yang sama.",
          ),
          _buildInfo(
            context,
            "Tanggal Mulai",
            startAt,
            "Tanggal dimulainya pembelian paket roaming untuk pertama kalinya.",
          ),
          _buildInfo(
            context,
            "Berakhir Pada",
            endAt,
            "Tanggal berakhir masa paket roaming dihitung berdasarkan pembelian paket roaming terakhir. Tanggal tersebut akan otomatis diperpanjang apabila Anda membeli atau memperpanjang paket roaming menggunakan nomor telepon yang sama.",
          ),
          _buildInfo(
            context,
            "Sisa Masa Aktif",
            "$sisaMasaAktif Hari Lagi",
            "Sisa masa aktif dihitung dari selisih antara tanggal saat ini dan tanggal berakhir paket roaming.",
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(
    BuildContext c,
    String label,
    String data,
    String explanation,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () async => await _showInfo(c, label, explanation),
            child: Row(
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black54, fontSize: 12.5),
                ),
                Icon(
                  IconsaxPlusLinear.info_circle,
                  color: Colors.black54,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            data,
            maxLines: 2,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
          ),
        ),
      ],
    );
  }

  Future<void> _showInfo(
    BuildContext context,
    String title,
    String subtitle,
  ) async {
    final bottomBasedOS = Platform.isIOS ? 8.0 : 24.0;
    final bottomPadding = context.bottom + bottomBasedOS;
    await HapticFeedback.lightImpact();
    await showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        );
      },
    );
  }
}
