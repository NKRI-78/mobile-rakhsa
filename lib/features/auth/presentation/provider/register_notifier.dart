
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/data/models/passport.dart';

import 'package:firebase_auth/firebase_auth.dart' as fa;

import 'package:rakhsa/features/auth/domain/usecases/register.dart';
import 'package:rakhsa/features/auth/domain/usecases/register_passport.dart';
import 'package:rakhsa/features/auth/presentation/pages/register_otp.dart';
import 'package:rakhsa/features/document/domain/usecase/update_passport_use_case.dart';
import 'package:rakhsa/features/media/domain/usecases/upload_media.dart';

import 'package:rakhsa/global.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RegisterNotifier with ChangeNotifier {
  final UploadMediaUseCase mediaUseCase;
  final UpdatePassportUseCase updatePassport;

  final RegisterUseCase useCase;
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final RegisterPassportUseCase registerPassport;

  AuthModel _authModel = AuthModel();
  AuthModel get authModel => _authModel;

  String _message = "";
  String get message => _message;

  ProviderState _providerState = ProviderState.idle; 
  ProviderState get providerState => _providerState;

  // media passport 
  String _mediaPassport = '';
  String get mediaPassport => _mediaPassport;

  // media avatar 
  String _mediaAvatar = '';
  String get mediaAvatar => _mediaAvatar;

   // register google
  bool _ssoLoading = false;
  bool get ssoLoading => _ssoLoading;

  // user
  fa.User? _userGoogle;
  fa.User? get userGoogle => _userGoogle;

  // register passport
  Passport? _passport;
  Passport? get passport => _passport;
  bool _passportExpired = false;

  void _setPassport(PassportDataExtraction passportData){
    _passport = passportData.passport;
    _panelMinHeight = _panelMinHeightActualy;
    notifyListeners();

    // open panel
    _panelController.open();
  }

  bool get scanningSuccess => _passport != null && !_passportExpired;

  String _scanningText = '';
  String get scanningText => _scanningText;

  void _setScanningText(String message){
    _scanningText = message;
    notifyListeners();
  }

  // path
  String _passportPath = '';
  String get passportPath => _passportPath;
  bool get hasPath => _passportPath.isNotEmpty;

  // panel controller
  final _panelMinHeightActualy = kBottomNavigationBarHeight + 24;
  double _panelMinHeight = 0.0;
  double get panelMinHeight => _panelMinHeight;
  late PanelController _panelController;
  PanelController get panelController => _panelController;
  void registerPanelController(PanelController controller) {
    _panelController = controller;
  }

  RegisterNotifier({
    required this.mediaUseCase,
    required this.updatePassport,
    required this.useCase,
    required this.googleSignIn,
    required this.firebaseAuth,
    required this.registerPassport,
  });

  void setStateProviderState(ProviderState param) {
    _providerState = param;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> register({
    required String countryCode,
    required String passportNumber,
    required String fullName,
    required String nasionality,
    required String placeOfBirth,
    required String dateOfBirth,
    required String gender,
    required String dateOfIssue,
    required String dateOfExpiry,
    required String registrationNumber,
    required String issuingAuthority,
    required String mrzCode,
    required String email,
    required String emergencyContact,
    required String password,
  }) async {
    setStateProviderState(ProviderState.loading);

    final register = await useCase.execute(
      countryCode: countryCode,
        passportNumber: passportNumber,
        fullName: fullName,
        nasionality: nasionality,
        placeOfBirth: placeOfBirth,
        dateOfBirth: dateOfBirth,
        gender: gender,
        dateOfIssue: dateOfIssue,
        dateOfExpiry: dateOfExpiry,
        registrationNumber: registrationNumber,
        issuingAuthority: issuingAuthority,
        mrzCode: mrzCode,
        email: email,
        emergencyContact: emergencyContact,
        password: password
    );

    register.fold((l) {
      _message = l.message;
      setStateProviderState(ProviderState.error);
    }, (r) {
      _authModel = r;

      StorageHelper.saveUserId(userId: authModel.data?.user.id ?? "-");
      StorageHelper.saveUserEmail(email: authModel.data?.user.email ?? "-");
      StorageHelper.saveUserPhone(phone: authModel.data?.user.phone ?? "-");

      ShowSnackbar.snackbarOk("Silahkan periksa alamat E-mail $email untuk mengisi kode otp yang telah dikirimkan");

      Navigator.pushAndRemoveUntil(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) {
          return RegisterOtp(email: email);
        }
      ), (route) => false);

      setStateProviderState(ProviderState.loaded);
    });
  }


  Future<void> registerWithGoogle(BuildContext context) async {
    bool hasUser = firebaseAuth.currentUser != null;

    if (hasUser) {
      // navigate to register page
      Navigator.pushNamed(context, RoutesNavigation.registerPassport);
    } else {
      final connection = await Connectivity().checkConnectivity();
      if (connection == ConnectivityResult.mobile ||
          connection == ConnectivityResult.wifi ||
          connection == ConnectivityResult.vpn) {
        try {
          _ssoLoading = true;
          notifyListeners();

          final gUser = await googleSignIn.signIn();

          final gAuth = await gUser?.authentication;

          final credential = fa.GoogleAuthProvider.credential(
            accessToken: gAuth?.accessToken,
            idToken: gAuth?.idToken,
          );

          final user = await firebaseAuth.signInWithCredential(credential);

          _userGoogle = user.user;
          notifyListeners();

          ShowSnackbar.snackbarOk('Berhasil login sebagai ${user.user?.email}');
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, RoutesNavigation.registerPassport);
        } on fa.FirebaseAuthException catch (_) {
          _ssoLoading = false;
          notifyListeners();
        } catch (e) {
          _ssoLoading = false;
          notifyListeners();
        } finally {
          _ssoLoading = false;
          notifyListeners();
        }
      } else {
        // show snackbar
        ShowSnackbar.snackbarErr('Tidak ada koneksi internet');
      }
    }
  }

  Future<void> startScan(BuildContext context, String userId) async {
    try {
      final scanResult = await CunningDocumentScanner.getPictures(
        isGalleryImportAllowed: true,
        noOfPages: 1,
      );

      if (scanResult != null) {
        _passportPath = scanResult.last;
        notifyListeners();

        _setScanningText('Pemindaian Paspor sedang berlangsung');

        final passportData = await registerPassport.execute(scanResult.last);

        passportData.fold((failure) {
          _resetScan();
          FailureDocumentDialog.launch(
            context,
            content:
                'Kami mengalami kendala saat memproses paspor Anda. [${failure.message}]',
            actionCallback: () async {
              Navigator.of(context).pop(); // close dialog
              await startScan(context, userId);
            },
          );
        }, (passportData) async {
          // lakukan cek apakah ada error saat scan passport
          if (passportData.errorScanning) {
            _resetScan();
            FailureDocumentDialog.launch(
              context,
              content:
              'Dokumen yang dipindai bukan paspor atau tidak dikenali. Pastikan Anda memindai halaman identitas paspor yang valid.',
              actionCallback: () async {
                Navigator.of(context).pop(); // close dialog
                await startScan(context, userId);
              },
            );
          } else {

            _setScanningText('Memvalidasi Dokumen');

            // validasi apakah ini visa
            if (passportData.passport?.mrzCode?[0].contains('V') ?? false) {
              _resetScan();
              FailureDocumentDialog.launch(
                context,
                content:
                'Dokumen yang dipindai terdeteksi sebagai visa. Pastikan Anda memindai halaman identitas paspor yang valid.',
                actionCallback: () async {
                  Navigator.of(context).pop(); // close dialog
                  await startScan(context, userId);
                },
              );

              // validasi berhasil menyatakan bahwa ini adalah passport
            } else if (passportData.passport?.mrzCode?[0].contains('P') ?? false) {
              final expiryDate = passportData.passport?.dateOfExpiry;
              bool expiryPassport = getExpiredPassport(expiryDate);
              _passportExpired = expiryPassport;
              notifyListeners();
              
              // jika passport sudah kadaluarsa
              if (expiryPassport) {
                _resetScan();
                FailureDocumentDialog.launch(
                  context,
                  content: 'Paspor Anda sudah tidak berlaku sejak ${DateFormat('dd MMMM yyyy', 'id').format(DateTime.parse(expiryDate ?? '2025-02-15'))}.' 
                  ' Silakan lakukan perpanjangan di kantor imigrasi terdekat untuk melanjutkan.',
                  showScanButton: false,
                );

                // positive case [scan berhasil]
              } else {
                final uploadPassportToServer = await mediaUseCase.execute(
                  file: File(_passportPath),
                  folderName: 'passport',
                );

                uploadPassportToServer.fold((failure) {
                  ShowSnackbar.snackbarErr(failure.message);
                  notifyListeners();
                }, (picture) async {
                  _mediaPassport = picture.path;
                  notifyListeners();
                });

                _setPassport(passportData);
              }

              // error saat membaca kode mrz (karakter pertama tidak terbaca)
            } else {
              _resetScan();
              FailureDocumentDialog.launch(
                context,
                content:
                  'Kode MRZ tidak lengkap atau tidak jelas. '
                  'Pastikan seluruh bagian MRZ di bagian bawah paspor terlihat jelas dalam satu frame, tidak terpotong, dan cahaya cukup. '
                  'Pegang perangkat dengan stabil dan coba pindai ulang.',
                actionCallback: () async {
                  Navigator.of(context).pop(); // close dialog
                  await startScan(context, userId);
                },
              );
            }
          }
        });
      }
    } catch (e) {
      // kondisi untuk catch error dari _launchPromt
      // karena error pada launch promt mengembalikan null
      // progam ini hanya untuk error pada scan document
      if (_passport == null) {
        _passportPath = '';

        // back to previous page
        if (context.mounted) Navigator.of(context).pop();
        await Future.delayed(const Duration(seconds: 1), () {
          ShowSnackbar.snackbarDefault('Register Paspor Dibatalkan');
        });
      }
    }
  }

  bool getExpiredPassport(String? expiryDateStr){
    try {
      if(expiryDateStr != null) {
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

  void _resetScan() {
    _passportPath = '';
    notifyListeners();
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
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
                            onTap: actionCallback ?? (){},
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