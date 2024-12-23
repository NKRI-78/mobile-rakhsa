import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/provider/resend_otp_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/verify_otp_notifier.dart';

class RegisterOtp extends StatefulWidget {
  const RegisterOtp({super.key, required this.email});

  final String email;

  @override
  State<RegisterOtp> createState() => RegisterOtpState();
}

class RegisterOtpState extends State<RegisterOtp> {

  final CountDownController controller = CountDownController();
  
  late VerifyOtpNotifier verifyOtpNotifier;
  late ResendOtpNotifier resendOtpNotifier;

  String parseSeconds(int value) {
    value++;
    if (value > 1) {
      return "Kirim ulang lagi dalam $value detik";
    }
    return "Kirim ulang lagi dalam $value detik";
  }

  Future<void> submitVerifyOtp() async {
    String email = widget.email;
    String otp = verifyOtpNotifier.valueOtp;

    await verifyOtpNotifier.verifyOtp(
      email: email, 
      otp: otp
    );

    if(verifyOtpNotifier.message != "") {
      ShowSnackbar.snackbarErr(verifyOtpNotifier.message);
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    
    verifyOtpNotifier = context.read<VerifyOtpNotifier>();
    resendOtpNotifier = context.read<ResendOtpNotifier>();
  }

  @override
  void dispose() {
    super.dispose();
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
                            image: AssetImage(loginOrnament)
                          )
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Text("Kode OTP",
                            style: robotoRegular.copyWith(
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
                          child: Image.asset("assets/images/forward.png"),
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
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "Silahkan periksa E-mail Anda ",
                            style: robotoRegular.copyWith(
                              fontSize: fontSizeDefault,
                              color: whiteColor,
                            ),
                            children: [
                              TextSpan(
                                text: widget.email,
                                style: robotoRegular.copyWith(
                                  fontSize: fontSizeDefault,
                                  color: yellowColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: " untuk mengisi Kode OTP pada kolom yang tersedia",
                                style: robotoRegular.copyWith(
                                  fontSize: fontSizeDefault,
                                  color: whiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        OtpTextField(
                          fieldWidth: 55,
                          fieldHeight: 55,
                          numberOfFields: 4,
                          borderColor: yellowColor,
                          showFieldAsBox: true,
                          textStyle: robotoRegular.copyWith(
                            color: whiteColor,
                            fontSize: 25.0
                          ),
                          cursorColor: ColorResources.white,
                          focusedBorderColor: yellowColor,
                          onCodeChanged: (String code) {
                            verifyOtpNotifier.valueOtp = code;
                          },
                          contentPadding: const EdgeInsets.only(top: 10.0),
                          onSubmit: (String verificationCode) async {
                            verifyOtpNotifier.valueOtp = verificationCode;
                            await submitVerifyOtp();
                          }, 
                        ),

                        const SizedBox(height: 10.0),

                        context.watch<VerifyOtpNotifier>().onCompletedOtp 
                        ? RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Klik disini',
                                  style: robotoRegular.copyWith(
                                    color: yellowColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    await resendOtpNotifier.resendOtp(
                                      email: widget.email, 
                                    );
                                    controller.restart(duration: 120);
                                    verifyOtpNotifier.onStartTimerOtp();
                                  },
                                ),
                                const TextSpan(text: " apabila belum mendapatkan Kode OTP"),
                              ]
                            ),
                          ) 
                        : const SizedBox()

                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      right: 20.0,
                      left: 20.0,
                      bottom: 20.0
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircularCountDownTimer(
                          duration: 120,
                          initialDuration: 0,
                          width: 40.0,
                          height: 40.0,
                          ringColor: Colors.transparent,
                          ringGradient: null,
                          fillColor: yellowColor.withOpacity(0.4),
                          fillGradient: null,
                          backgroundColor: yellowColor,
                          backgroundGradient: null,
                          strokeWidth: 10.0,
                          strokeCap: StrokeCap.round,
                          textStyle: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: ColorResources.white,
                            fontWeight: FontWeight.bold
                          ),
                          textFormat: CountdownTextFormat.S,
                          isReverse: true,
                          isReverseAnimation: true,
                          isTimerTextShown: true,
                          autoStart: true,
                          controller: controller,
                          onStart: () {},
                          onComplete: () {
                            verifyOtpNotifier.onCompletedTimerOtp();
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}