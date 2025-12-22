import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/core/constants/assets.dart';
import 'package:rakhsa/widgets/overlays/status_bar_style.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusBarStyle.light(
      child: Scaffold(
        body: Stack(
          children: [
            // bg
            Positioned.fill(
              child: Image.asset(Assets.imagesOnBoardingBg, fit: .fill),
            ),

            // content
            const _OnBoardingContentView(),
          ],
        ),
      ),
    );
  }
}

class _OnBoardingContentView extends StatefulWidget {
  const _OnBoardingContentView();

  @override
  State<_OnBoardingContentView> createState() => __OnBoardingContentViewState();
}

class __OnBoardingContentViewState extends State<_OnBoardingContentView> {
  late PageController _pageController;

  int _currentPage = 0;

  final _contents = [
    _OnBoardingData(
      message:
          'Keamanan di ujung jari Anda!. Gunakan fitur SOS di aplikasi kami untuk mendapatkan bantuan cepat saat darurat. Aktifkan sekarang dan tetap terlindungi di setiap peristiwa!',
      asset: Assets.imagesOnBoardingContent1,
    ),
    _OnBoardingData(
      message:
          'Rekam dan kirim video kejadian secara real-time! Bukti kuat untuk keamanan Anda—langsung terkirim dan tersimpan sebagai alat bukti resmi. Lindungi diri dengan teknologi cerdas!',
      asset: Assets.imagesOnBoardingContent2,
    ),
    _OnBoardingData(
      message:
          'Tanggap cepat melalui chat langsung! Kami siap membantu Anda dalam situasi darurat, kapan pun dan di mana pun!',
      asset: Assets.imagesOnBoardingContent3,
    ),
  ];

  bool get _lastIndex => (_currentPage == _contents.length - 1);

  void _actionOnTap(BuildContext c) async {
    if (_lastIndex) {
      await c.read<AuthProvider>().completeOnBoarding();
      if (c.mounted) WelcomeRoute().go(c);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.ease,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // content
        PageView(
          controller: _pageController,
          onPageChanged: (page) => setState(() {
            _currentPage = page;
          }),
          children: _contents.map((content) {
            return _ContentView(content);
          }).toList(),
        ),

        // on boarding action button && page indicator
        Positioned(
          bottom: 40,
          left: 50,
          right: 50,
          child: Column(
            mainAxisSize: .min,
            children: [
              // page indicator
              _pageIndicator(),
              const SizedBox(height: 16),

              // action button
              _actionButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pageIndicator() {
    return Row(
      mainAxisSize: .min,
      children: List.generate(_contents.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: .only(right: (index == 2) ? 0 : 8),
          height: 8,
          width: (_currentPage == index) ? 30 : 8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: .circular(100),
          ),
        );
      }),
    );
  }

  Widget _actionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _actionOnTap(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: .circular(8)),
        ),
        child: Text(
          _lastIndex ? 'Selesai' : 'Lanjutkan',
          style: TextStyle(fontWeight: .bold),
        ),
      ),
    );
  }
}

class _ContentView extends StatelessWidget {
  const _ContentView(this.content);

  final _OnBoardingData content;

  @override
  Widget build(BuildContext context) {
    MediaQueryData device = MediaQuery.of(context);
    double paddingTop = device.padding.top + kToolbarHeight;
    double messageContainerHeight = device.size.height * 0.32;

    return Padding(
      padding: .only(top: paddingTop, right: 16, left: 16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            // asset
            Expanded(child: Image.asset(content.asset)),
            const SizedBox(height: 16),

            // message container
            Container(
              padding: .all(16),
              height: messageContainerHeight,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.4),
                borderRadius: .vertical(top: .circular(16)),
              ),
              child: Text(
                content.message,
                textAlign: .center,
                style: TextStyle(color: Colors.white, fontWeight: .w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnBoardingData {
  final String message;
  final String asset;

  _OnBoardingData({required this.message, required this.asset});
}
