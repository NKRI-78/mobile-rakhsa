import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Stack(
        children: [
          // bg
          Positioned.fill(
            child: Image.asset(AssetSource.bgOnBoarding, fit: BoxFit.fill),
          ),

          // content
          const _OnBoardingContentView(),
        ],
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
      asset: AssetSource.onBoarding1,
    ),
    _OnBoardingData(
      message:
          'Rekam dan kirim video kejadian secara real-time! Bukti kuat untuk keamanan Anda—langsung terkirim dan tersimpan sebagai alat bukti resmi. Lindungi diri dengan teknologi cerdas!',
      asset: AssetSource.onBoarding3,
    ),
    _OnBoardingData(
      message:
          'Tanggap cepat melalui chat langsung! Kami siap membantu Anda dalam situasi darurat, kapan pun dan di mana pun!',
      asset: AssetSource.onBoarding2,
    ),
  ];

  bool get _lastIndex => (_currentPage == _contents.length - 1);

  void _actionOnTap(BuildContext context) async {
    if (_lastIndex) {
      // set data ketika key tidak tersedia di prefs
      if (!StorageHelper.containsKey("on_boarding_key")) {
        await StorageHelper.write("on_boarding_key", "ob");
      }
      if (context.mounted) {
        Navigator.pushNamed(context, RoutesNavigation.welcomePage);
      }
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
            mainAxisSize: MainAxisSize.min,
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
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_contents.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: EdgeInsets.only(right: (index == 2) ? 0.0 : 8.0),
          height: 8,
          width: (_currentPage == index) ? 30 : 8,
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(100),
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
          backgroundColor: whiteColor,
          foregroundColor: blackColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          _lastIndex ? 'Selesai' : 'Lanjutkan',
          style: robotoRegular.copyWith(fontWeight: FontWeight.bold),
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
      padding: EdgeInsets.only(top: paddingTop, right: 16, left: 16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            // asset
            Expanded(child: Image.asset(content.asset)),
            const SizedBox(height: 16),

            // message container
            Container(
              padding: const EdgeInsets.all(16),
              height: messageContainerHeight,
              decoration: BoxDecoration(
                color: redColor.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Text(
                content.message,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  color: whiteColor,
                  fontWeight: FontWeight.w600,
                ),
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
