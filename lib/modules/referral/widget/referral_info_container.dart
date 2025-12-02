import 'package:flutter/material.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/repositories/referral/model/referral.dart';

class ReferralInfoContainer extends StatelessWidget {
  const ReferralInfoContainer({super.key, this.referral, this.package});

  final ReferralData? referral;
  final ReferralPackage? package;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final namaPaket =
        referral?.package?.packageKeyword ?? package?.packageKeyword ?? "-";
    final end = referral?.package?.endAt ?? package?.endAt ?? now;
    final diff = end.difference(now);
    final sisaMasaAktif = (diff.isNegative ? Duration.zero : diff).inDays;
    final berakhirPada = (referral?.package?.endAt ?? package?.endAt ?? now)
        .format("dd MMMM yyyy");

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 0.7),
      ),
      child: Column(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow("Nama Paket", namaPaket),
          Divider(),
          _buildRow("Status", "Aktif"),
          _buildRow("Sisa Masa Aktif", "$sisaMasaAktif Hari"),
          _buildRow("Berakhir Pada", berakhirPada),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black54),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            data,
            maxLines: 2,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
