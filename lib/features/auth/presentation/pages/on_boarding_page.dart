import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // bg
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              AssetSource.bgOnBoarding,
              fit: BoxFit.cover,
            ),
          ),
          
          // content
          const OnBoardingContentView(),
        ],
      ),
    );
  }
}

class OnBoardingContentView extends StatefulWidget {
  const OnBoardingContentView({super.key});

  @override
  State<OnBoardingContentView> createState() => _OnBoardingContentViewState();
}

class _OnBoardingContentViewState extends State<OnBoardingContentView> {
  late PageController _pageController;

  int _currentPage = 0;

  final _contents = [
    OnBoardingData(
      message: 'Keamanan di ujung jari Anda!. Gunakan fitur SOS di aplikasi kami untuk mendapatkan bantuan cepat saat darurat. Aktifkan sekarang dan tetap terlindungi di setiap momen!', 
      asset: AssetSource.onBoarding1,
    ),
    OnBoardingData(
      message: 'Respon cepat melalui chat langsung! Kami siap membantu Anda dalam situasi darurat, kapan pun dan di mana pun!', 
      asset: AssetSource.onBoarding2,
    ),
    OnBoardingData(
      message: 'Rekam dan kirim video kejadian secara real-time! Bukti kuat untuk keamanan Anda—langsung terkirim dan tersimpan sebagai alat bukti resmi. Lindungi diri dengan teknologi cerdas!', 
      asset: AssetSource.onBoarding3,
    ),
  ];

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
            return Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
                right: 16,
                left: 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    // asset
                    Expanded(
                      child: Image.asset(content.asset),
                    ),
                    const SizedBox(height: 16),
                
                    // container
                    Container(
                      padding: const EdgeInsets.all(16),
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                        color: redColor.withOpacity(0.4),
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
          }).toList(),
        ),

        // button lanjut
        Positioned(
          bottom: 50,
          left: 50,
          right: 50,
          child: ElevatedButton(
            onPressed: () {
              if (_currentPage == 2) {
                // navigate to welcome page
                Navigator.pushNamed(context, RoutesNavigation.welcomePage);
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 600), 
                  curve: Curves.ease,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: whiteColor,
              foregroundColor: blackColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              (_currentPage == 2) 
                  ? 'Selesai' 
                  : 'Lanjutkan',
              style: robotoRegular.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OnBoardingData {
  final String message;
  final String asset;

  OnBoardingData({required this.message, required this.asset});
} 