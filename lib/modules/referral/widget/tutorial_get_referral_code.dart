import 'package:flutter/material.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';

class TutorialGetReferralCode extends StatelessWidget {
  const TutorialGetReferralCode({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(left: 4),
        title: Text(
          "Bagaimana cara mendapatkan referral link?",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1 Beli paket internet roaming dari operator.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                "2 Terima SMS berisi link aktivasi.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                "3 Ketuk link tersebut untuk membuka Marlinda.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                "4 Lanjutkan registrasi dengan nomor yang terdaftar roaming.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
