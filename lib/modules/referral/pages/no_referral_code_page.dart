import 'package:flutter/material.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/modules/referral/widget/tutorial_get_referral_code.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/widgets/components/app_button.dart';
import 'package:rakhsa/widgets/lottie/lottie_animation.dart';
import 'package:rakhsa/widgets/overlays/status_bar_style.dart';

class NoReferralCodePage extends StatelessWidget {
  const NoReferralCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusBarStyle(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            context.top + 16,
            16,
            context.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              50.spaceY,
              Expanded(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.all(80),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.08),
                    ),
                    child: LottieAnimation("assets/animations/referral.lottie"),
                  ),
                ),
              ),

              50.spaceY,

              Text(
                "Akses Marlinda Memerlukan Referral",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              16.spaceY,

              Text(
                "Saat ini Marlinda hanya dapat digunakan oleh pelanggan yang memiliki kode atau link referral dari paket internet roaming. Silakan berlangganan paket roaming untuk mendapatkan link aktivasi melalui pesan SMS dan melanjutkan proses registrasi.",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),

              10.spaceY,

              TutorialGetReferralCode(),

              20.spaceY,

              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: "Mengerti",
                  onPressed: () => WelcomeRoute().go(context),
                  borderRadius: BorderRadiusGeometry.circular(100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
