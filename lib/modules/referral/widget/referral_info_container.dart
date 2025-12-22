import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/repositories/referral/model/referral.dart';
import 'package:rakhsa/service/haptic/haptic_service.dart';

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
      padding: .all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(12),
        border: .all(color: Colors.grey.shade400, width: 0.7),
      ),
      child: Column(
        spacing: 8,
        mainAxisSize: .min,
        children: [
          _buildInfo(
            context,
            "Nama Paket",
            namaPaket,
            "Nama layanan Marlinda yang aktif untuk saat ini.",
          ),
          Divider(),
          _buildInfo(
            context,
            "Status",
            "Aktif",
            "Status aktivasi layanan Marlinda ditentukan oleh sisa masa aktif. Jika masa aktif layanan Marlinda telah berakhir, aplikasi akan otomatis melakukan logout. Untuk dapat kembali menggunakan Marlinda, Anda perlu membeli paket roaming kembali dan login menggunakan akun yang sama.",
          ),
          _buildInfo(
            context,
            "Tanggal Mulai",
            startAt,
            "Tanggal dimulainya pembelian layanan Marlinda untuk pertama kalinya.",
          ),
          _buildInfo(
            context,
            "Berakhir Pada",
            endAt,
            "Tanggal berakhir masa layanan Marlinda dihitung berdasarkan pembelian layanan Marlinda terakhir. Tanggal tersebut akan otomatis diperpanjang apabila Anda membeli atau memperpanjang layanan Marlinda menggunakan nomor telepon yang sama.",
          ),
          _buildInfo(
            context,
            "Sisa Masa Aktif",
            "$sisaMasaAktif Hari Lagi",
            "Sisa masa aktif dihitung dari selisih antara tanggal saat ini dan tanggal berakhir layanan Marlinda.",
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
      mainAxisAlignment: .spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () async => await _showInfo(c, label, explanation),
            child: Row(
              spacing: 4,
              mainAxisSize: .min,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: .ellipsis,
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
            textAlign: .end,
            overflow: .ellipsis,
            style: TextStyle(fontWeight: .w600, fontSize: 12.5),
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
    await HapticService.instance.lightImpact();
    await showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(16)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: .fromLTRB(16, 0, 16, bottomPadding),
          child: Column(
            spacing: 16,
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              Text(title, style: TextStyle(fontSize: 17, fontWeight: .bold)),
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
