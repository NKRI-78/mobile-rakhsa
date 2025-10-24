import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/data/models/passport.dart';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:rakhsa/features/auth/domain/usecases/check_register_status.dart';

import 'package:rakhsa/features/auth/domain/usecases/register.dart';
import 'package:rakhsa/features/auth/domain/usecases/register_passport.dart';
import 'package:rakhsa/features/media/domain/usecases/upload_media.dart';

import 'package:rakhsa/global.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class RegisterNotifier with ChangeNotifier {
  final UploadMediaUseCase mediaUseCase;
  final CheckRegisterStatusUseCase checkRegisterStatusUseCase;

  final RegisterUseCase useCase;
  final FirebaseAuth firebaseAuth;
  // final GoogleSignIn googleSignIn;
  final RegisterPassportUseCase registerPassport;

  AuthModel _authModel = AuthModel();
  AuthModel get authModel => _authModel;

  String _message = "";
  String get message => _message;

  ProviderState _providerState = ProviderState.idle;
  ProviderState get providerState => _providerState;

  // user
  fa.User? _userGoogle;
  fa.User? get userGoogle => _userGoogle;

  // register passport
  Passport? _passport;
  Passport? get passport => _passport;

  // path
  String _passportPath = '';
  String get passportPath => _passportPath;
  bool get hasPath => _passportPath.isNotEmpty;

  // panel controller
  double _panelMinHeight = 0.0;
  double get panelMinHeight => _panelMinHeight;

  RegisterNotifier({
    required this.mediaUseCase,
    required this.useCase,
    // required this.googleSignIn,
    required this.firebaseAuth,
    required this.registerPassport,
    required this.checkRegisterStatusUseCase,
  });

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    notifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String emergencyContact,
    required String password,

    // required String email,
    // required String countryCode,
    // required String passportNumber,
    // required String nasionality,
    // required String placeOfBirth,
    // required String dateOfBirth,
    // required String gender,
    // required String dateOfIssue,
    // required String dateOfExpiry,
    // required String registrationNumber,
    // required String issuingAuthority,
    // required String mrzCode,
  }) async {
    setStateProviderState(ProviderState.loading);

    final register = await useCase.execute(
      fullName: fullName,
      emergencyContact: emergencyContact,
      password: password,

      // email: email,
      // countryCode: countryCode,
      // passportNumber: passportNumber,
      // nasionality: nasionality,
      // placeOfBirth: placeOfBirth,
      // dateOfBirth: dateOfBirth,
      // gender: gender,
      // dateOfIssue: dateOfIssue,
      // dateOfExpiry: dateOfExpiry,
      // registrationNumber: registrationNumber,
      // issuingAuthority: issuingAuthority,
      // mrzCode: mrzCode,
    );

    register.fold(
      (l) {
        _message = l.message;
        setStateProviderState(ProviderState.error);
      },
      (r) {
        _authModel = r;

        StorageHelper.saveUserId(userId: authModel.data?.user.id ?? "-");
        StorageHelper.saveUserEmail(email: authModel.data?.user.email ?? "-");
        StorageHelper.saveUserPhone(phone: authModel.data?.user.phone ?? "-");

        StorageHelper.saveToken(token: authModel.data?.token ?? "-");

        Navigator.pushNamedAndRemoveUntil(
          navigatorKey.currentContext!,
          RoutesNavigation.dashboard,
          (route) => false,
        );

        // ShowSnackbar.snackbarOk(
        //   "Silahkan periksa alamat E-mail $email untuk mengisi kode otp yang telah dikirimkan",
        // );

        // Navigator.pushAndRemoveUntil(
        //   navigatorKey.currentContext!,
        //   MaterialPageRoute(
        //     builder: (context) {
        //       return RegisterOtp(email: email);
        //     },
        //   ),
        //   (route) => false,
        // );

        setStateProviderState(ProviderState.loaded);
      },
    );
  }

  Future<void> registerWithGoogle(BuildContext context) async {
    // bool hasUser = firebaseAuth.currentUser != null;

    // if (hasUser) {
    //   // navigate to register page
    //   await ScanningInstructionsBottomSheet.launch(context);
    // } else {
    //   final connection = await Connectivity().checkConnectivity();
    //   if (connection == ConnectivityResult.mobile ||
    //       connection == ConnectivityResult.wifi ||
    //       connection == ConnectivityResult.vpn) {
    //     try {
    //       _ssoLoading = true;
    //       notifyListeners();

    //       final gUser = await googleSignIn.signIn();

    //       final gAuth = await gUser?.authentication;

    //       final credential = fa.GoogleAuthProvider.credential(
    //         accessToken: gAuth?.accessToken,
    //         idToken: gAuth?.idToken,
    //       );

    //       final user = await firebaseAuth.signInWithCredential(credential);

    //       _userGoogle = user.user;
    //       notifyListeners();

    //       ShowSnackbar.snackbarOk('Berhasil login sebagai ${user.user?.email}');
    //       // ignore: use_build_context_synchronously
    //       await ScanningInstructionsBottomSheet.launch(context);
    //     } on fa.FirebaseAuthException catch (_) {
    //       _ssoLoading = false;
    //       notifyListeners();
    //     } catch (e) {
    //       _ssoLoading = false;
    //       notifyListeners();
    //     } finally {
    //       _ssoLoading = false;
    //       notifyListeners();
    //     }
    //   } else {
    //     // show snackbar
    //     ShowSnackbar.snackbarErr('Tidak ada koneksi internet');
    //   }
    // }
  }
  bool getExpiredPassport(String? expiryDateStr) {
    try {
      if (expiryDateStr != null) {
        DateTime now = DateTime.now();
        DateTime expiryDate = DateTime.parse(expiryDateStr);

        return expiryDate.isBefore(now);
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  String? getPassportPeriod(String? expiryDateStr) {
    try {
      if (expiryDateStr != null) {
        DateTime now = DateTime.now();
        DateTime expiryDate = DateTime.parse(expiryDateStr);

        if (expiryDate.isBefore(now)) {
          return "Paspor sudah kadaluwarsa";
        }

        final totalDays = expiryDate.difference(now).inDays;
        final years = totalDays ~/ 365;
        final remainingDaysAfterYears = totalDays % 365;
        final months = remainingDaysAfterYears ~/ 30;
        final remainingDaysAfterMonths = remainingDaysAfterYears % 30;
        final weeks = remainingDaysAfterMonths ~/ 7;
        final days = remainingDaysAfterMonths % 7;

        if (years > 0 && months > 0) {
          return "$years tahun $months bulan";
        } else if (years > 0) {
          return "$years tahun";
        } else if (months > 0) {
          return "$months bulan";
        } else if (weeks > 0) {
          return "$weeks minggu";
        } else {
          return "$days hari";
        }
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  void deleteData() {
    _passportPath = '';
    _passport = null;
    _panelMinHeight = 0.0;
  }
}

class ScanningInstructionsBottomSheet extends StatelessWidget {
  const ScanningInstructionsBottomSheet._();

  static Future<void> launch(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const ScanningInstructionsBottomSheet._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // title
            Text(
              'Siapkan Paspor Anda',
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // message
            const Text(
              'Aplikasi akan melakukan pemindaian paspor. Harap siapkan dokumen paspor yang valid untuk proses yang lancar.',
              textAlign: TextAlign.center,
              style: robotoRegular,
            ),
            const SizedBox(height: 24),

            // confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.pushNamed(
                  //   context,
                  //   RoutesNavigation.registerPassport,
                  // )
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: whiteColor,
                  backgroundColor: primaryColor,
                  side: const BorderSide(color: whiteColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Selanjutnya'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FailureDocumentDialog extends StatelessWidget {
  const FailureDocumentDialog({
    super.key,
    this.actionCallback,
    required this.content,
    this.showScanButton = true,
  });

  final VoidCallback? actionCallback;
  final String content;
  final bool showScanButton;

  static void launch(
    BuildContext context, {
    required String content,
    VoidCallback? actionCallback,
    bool showScanButton = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: FailureDocumentDialog(
            content: content,
            actionCallback: actionCallback,
            showScanButton: showScanButton,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 300,
            padding: const EdgeInsets.only(
              top: 60.0,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 5,
                      child: CustomButton(
                        isBorderRadius: true,
                        isBoxShadow: false,
                        btnColor: ColorResources.grey,
                        btnTextColor: ColorResources.white,
                        onTap: () {
                          Navigator.of(context).pop(); // close dialog
                          Navigator.of(context).pop(); // back
                        },
                        btnTxt: 'Kembali',
                      ),
                    ),
                    if (showScanButton)
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: CustomButton(
                            isBorderRadius: true,
                            isBoxShadow: false,
                            btnColor: ColorResources.error,
                            btnTextColor: ColorResources.white,
                            onTap: actionCallback ?? () {},
                            btnTxt: "Scan Ulang",
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: -60,
            child: Image.asset(
              AssetSource.passportError,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
