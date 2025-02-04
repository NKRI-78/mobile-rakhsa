import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/common/constants/theme.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/features/auth/presentation/provider/passport_scanner_notifier.dart';

import 'package:rakhsa/features/auth/presentation/provider/register_notifier.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/shared/basewidgets/textinput/textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late RegisterNotifier registerNotifier;
  late PassportScannerNotifier passportNotifier;

  late TextEditingController emailC;
  late TextEditingController emergencyContactC;
  late TextEditingController passwordC;
  late TextEditingController passwordConfirmC;

  Future<void> submitRegister() async {
    String email = emailC.text.trim();
    String emergencyContact = emergencyContactC.text.trim();
    String password = passwordC.text.trim();
    String passConfirm = passwordConfirmC.text.trim();

    if (email.isEmpty) {
      ShowSnackbar.snackbarErr("Email tidak boleh kosong");
      return;
    }
    if (!email.isValidEmail()) {
      ShowSnackbar.snackbarErr("Email tidak valid");
      return;
    }
    if (emergencyContact.length < 10 || emergencyContact.length > 13) {
      ShowSnackbar.snackbarErr("No Darurat harus antara 10 hingga 13 digit");
      return;
    }
    if (password.isEmpty) {
      ShowSnackbar.snackbarErr("Password tidak boleh kosong");
      return;
    }
    if (passConfirm.isEmpty) {
      ShowSnackbar.snackbarErr("Password Konfirmasi tidak boleh kosong");
      return;
    }
    if (password != passConfirm) {
      ShowSnackbar.snackbarErr("Password Konfirmasi tidak sama");
      return;
    }

    await registerNotifier.register(
      countryCode: passportNotifier.passport?.countryCode ?? '',
      passportNumber: passportNotifier.passport?.passportNumber ?? '',
      fullName: passportNotifier.passport?.fullName ?? '',
      nasionality: passportNotifier.passport?.nationality ?? '',
      placeOfBirth: passportNotifier.passport?.placeOfBirth ?? '',
      dateOfBirth: passportNotifier.passport?.dateOfBirth ?? '',
      gender: passportNotifier.passport?.gender ?? '',
      dateOfIssue: passportNotifier.passport?.dateOfIssue ?? '',
      dateOfExpiry: passportNotifier.passport?.dateOfExpiry ?? '',
      registrationNumber: passportNotifier.passport?.registrationNumber ?? '',
      issuingAuthority: passportNotifier.passport?.issuingAuthority ?? '',
      mrzCode: passportNotifier.passport?.mrzCode ?? '',
      email: email,
      emergencyContact: emergencyContact,
      password: password
    );

    if (registerNotifier.message != "") {
      ShowSnackbar.snackbarErr(registerNotifier.message);
      return;
    }
  }

  @override
  void initState() {
    super.initState();

    emailC = TextEditingController();
    emergencyContactC = TextEditingController();
    passwordC = TextEditingController();
    passwordConfirmC = TextEditingController();

    registerNotifier = context.read<RegisterNotifier>();
    passportNotifier = context.read<PassportScannerNotifier>();
  }

  @override
  void dispose() {
    emailC.dispose();
    emergencyContactC.dispose();
    passwordC.dispose();
    passwordConfirmC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryColor,
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(
                top: 16.0, left: 20.0, right: 20.0, bottom: 16.0),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  Stack(
                    fit: StackFit.loose,
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.2,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: AssetImage(loginOrnament))),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image.asset("assets/images/signup-icon.png"),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Image.asset("assets/images/forward.png"),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Registrasi",
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.paddingSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: ColorResources.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // form
                  Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: CustomTextField(
                              controller: emailC,
                              labelText: 'Email',
                              hintText: "Email",
                              fillColor: Colors.transparent,
                              emptyText: "Email wajib di isi",
                              textInputType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: CustomTextField(
                              controller: emergencyContactC,
                              labelText: 'Kontak Darurat',
                              isPhoneNumber: true,
                              maxLength: 13,
                              hintText: "Kontak Darurat",
                              fillColor: Colors.transparent,
                              emptyText: "Kontak Darurat wajib di isi",
                              textInputType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: CustomTextField(
                              controller: passwordC,
                              labelText: "Kata Sandi",
                              isPassword: true,
                              hintText: "Kata Sandi",
                              fillColor: Colors.transparent,
                              emptyText: "Kata Sandi tidak boleh kosong",
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: CustomTextField(
                              controller: passwordConfirmC,
                              labelText: "Konfirmasi Kata Sandi",
                              isPassword: true,
                              hintText: "Konfirmasi Kata Sandi",
                              fillColor: Colors.transparent,
                              emptyText:
                                  "Konfirmasi Kata Sandi tidak boleh kosong",
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          CustomButton(
                            onTap: submitRegister,
                            isLoading: context
                                        .watch<RegisterNotifier>()
                                        .providerState ==
                                    ProviderState.loading
                                ? true
                                : false,
                            isBorder: false,
                            isBorderRadius: true,
                            isBoxShadow: false,
                            btnColor: ColorResources.white,
                            btnTxt: "Register",
                            loadingColor: primaryColor,
                            btnTextColor: ColorResources.black,
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ))
                ])),
          ),
        ));
  }
}
