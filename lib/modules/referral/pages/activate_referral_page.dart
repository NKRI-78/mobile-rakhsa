import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/modules/app/provider/referral/referral_provider.dart';
import 'package:rakhsa/modules/referral/widget/referral_info_container.dart';
import 'package:rakhsa/modules/referral/widget/tutorial_get_referral_code.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/widgets/components/app_button.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';
import 'package:rakhsa/widgets/lottie/lottie_animation.dart';
import 'package:rakhsa/widgets/overlays/status_bar_style.dart';

class ActivateReferralPage extends StatefulWidget {
  const ActivateReferralPage(this.uid, {super.key});

  final String uid;

  @override
  State<ActivateReferralPage> createState() => _ActivateReferralPageState();
}

class _ActivateReferralPageState extends State<ActivateReferralPage> {
  late ReferralProvider _referralProvider;
  @override
  void initState() {
    super.initState();
    _referralProvider = context.read<ReferralProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _referralProvider.activateReferralCode(widget.uid, Duration(seconds: 5));
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatusBarStyle(
      child: Consumer<ReferralProvider>(
        builder: (context, p, child) {
          return PopScope(
            canPop: p.state.isError,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (p.state.isSuccess) {
                AppDialog.showToast("Tekan tombol mulai");
              } else {
                AppDialog.showToast("Tunggu sampai proses selesai");
              }
            },
            child: Scaffold(
              backgroundColor: Colors.grey.shade50,
              body: Padding(
                padding: EdgeInsetsGeometry.fromLTRB(
                  16,
                  context.top + 16,
                  16,
                  context.bottom + 16,
                ),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: () {
                    if (p.state.isSuccess) {
                      return _buildSuccessState(p);
                    }
                    if (p.state.isError) {
                      return _buildErrorState(
                        p.state.error?.title,
                        p.state.error?.message,
                      );
                    }
                    return _buildLoadingState();
                  }(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessState(ReferralProvider p) {
    return Column(
      key: ValueKey("success"),
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: successColor.withValues(alpha: 0.08),
                  ),
                  child: LottieAnimation(
                    "assets/animations/checked.lottie",
                    width: 190,
                    height: 190,
                  ),
                ),
                16.spaceY,
                Text(
                  "Kode Referral Berhasil di Klaim",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        if (p.state.data != null)
          Text("Detail Roaming", style: TextStyle(fontWeight: FontWeight.w600)),

        if (p.state.data != null) ReferralInfoContainer(referral: p.state.data),

        10.spaceY,

        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: "Mulai",
            onPressed: () => DashboardRoute(fromRegister: true).go(context),
            borderRadius: BorderRadiusGeometry.circular(100),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String? errorTitle, String? errorMessage) {
    return Column(
      key: ValueKey("error"),
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
          errorTitle ?? "-",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),

        16.spaceY,

        Text(
          errorMessage ?? "-",
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),

        10.spaceY,

        TutorialGetReferralCode(),

        20.spaceY,

        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: "Tutup",
            onPressed: () => WelcomeRoute().go(context),
            borderRadius: BorderRadiusGeometry.circular(100),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      key: ValueKey("loading"),
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: LottieAnimation("assets/animations/loading.lottie"),
          ),

          Text(
            "Mengaktifkan Kode Referral",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Text(
            "Tunggu sebentar. Jangan keluar dari halaman atau menutup aplikasi. Proses ini membutuhkan beberapa detik.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
