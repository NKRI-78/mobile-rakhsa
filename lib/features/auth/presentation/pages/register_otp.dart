import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class RegisterOtp extends StatefulWidget {
  const RegisterOtp({super.key});

  @override
  State<RegisterOtp> createState() => _RegisterOtpState();
}

class _RegisterOtpState extends State<RegisterOtp> {
  bool _startTimer = false;

  final StopWatchTimer _timer = StopWatchTimer(
    mode: StopWatchMode.countDown,
    presetMillisecond: StopWatchTimer.getMilliSecFromSecond(40),
  );

  String _parseSeconds(int value) {
    value++;
    if (value > 1) {
      return "Kirim ulang lagi dalam $value detik";
    }
    return "Kirim ulang lagi dalam $value detik";
  }

  @override
  void initState() {
    super.initState();

    _timer.fetchEnded.listen((value) {
      _startTimer = false;
      _timer.onResetTimer();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    fit: StackFit.loose,
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.15,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage(loginOrnamen)
                          )
                        ),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Text(
                            "Kode OTP",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: fontSizeOverLarge
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Image.asset(
                            "assets/images/forward.png"
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Masukan Kode OTP pada kolom yang tersedia",
                          style: TextStyle(
                            fontSize: fontSizeDefault,
                            color: whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                      height: 20,
                      ),
                      OtpTextField(
                        fieldWidth: 55,
                        fieldHeight: 55,
                        numberOfFields: 4,
                        borderColor: const Color(0xFF512DA8),
                        //set to true to show as box or false to show as dash
                        showFieldAsBox: true,
                        textStyle: const TextStyle(
                          color: whiteColor,
                          fontSize: 25
                        ),
                        //runs when a code is typed in
                        onCodeChanged: (String code) {},
                        
                        contentPadding: const EdgeInsets.only(top: 10),
                        //runs when every textfield is filled
                        onSubmit: (String verificationCode) {}, // end onSubmit
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _startTimer
                    ? StreamBuilder<int>(
                        stream: _timer.secondTime,
                        initialData: _timer.initialPresetTime,
                        builder: (context, snap) {
                          final value = snap.data ?? 0;
                          return Text(
                            _parseSeconds(value),
                            style: const TextStyle(color: whiteColor),
                          );
                        })
                      : RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'Klik disini',
                              style: const TextStyle(
                                color: yellowColor,
                              ),
                              recognizer: TapGestureRecognizer()
                              ..onTap = () {},
                            ),
                            const TextSpan(
                                text:
                                    " apabila belum mendapatkan Kode OTP"),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: CustomButton(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DashboardScreen()));
                  },
                  isBorder: false,
                  isBorderRadius: true,
                  isBoxShadow: false,
                  btnColor: whiteColor,
                  btnTxt: "Daftar",
                  btnTextColor: blackColor,
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}