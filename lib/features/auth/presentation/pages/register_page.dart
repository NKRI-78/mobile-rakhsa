import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/utils/color_resources.dart';

import 'package:rakhsa/common/constants/theme.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';

import 'package:rakhsa/features/auth/presentation/provider/register_notifier.dart';
import 'package:rakhsa/helper/extensions.dart';
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
  // late PassportScannerNotifier passportNotifier;

  late TextEditingController fullnameC;
  // late TextEditingController emailC;
  late TextEditingController emergencyContactC;
  late TextEditingController passwordC;
  late TextEditingController passwordConfirmC;

  Future<void> submitRegister() async {
    String fullname = fullnameC.text.trim();
    // String email = emailC.text.trim();
    String emergencyContact = PhoneNumberFormatter.unmask(
      emergencyContactC.text.trim(),
    );
    String password = passwordC.text.trim();
    String passConfirm = passwordConfirmC.text.trim();

    if (fullname.isEmpty) {
      ShowSnackbar.snackbarErr("Nama Lengkap tidak boleh kosong");
      return;
    }
    // if (email.isEmpty) {
    //   ShowSnackbar.snackbarErr("Email tidak boleh kosong");
    //   return;
    // }
    // if (!email.isValidEmail()) {
    //   ShowSnackbar.snackbarErr("Email tidak valid");
    //   return;
    // }
    if (emergencyContact.length < 10 || emergencyContact.length > 13) {
      ShowSnackbar.snackbarErr("Kontak harus antara 10 hingga 13 digit");
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
      fullName: fullname,
      emergencyContact: emergencyContact,
      password: password,
    );

    if (registerNotifier.message != "") {
      ShowSnackbar.snackbarErr(registerNotifier.message);
      return;
    }
  }

  @override
  void initState() {
    super.initState();

    fullnameC = TextEditingController();
    // emailC = TextEditingController();
    emergencyContactC = TextEditingController();
    passwordC = TextEditingController();
    passwordConfirmC = TextEditingController();

    registerNotifier = context.read<RegisterNotifier>();
  }

  @override
  void dispose() {
    fullnameC.dispose();
    // emailC.dispose();
    emergencyContactC.dispose();
    passwordC.dispose();
    passwordConfirmC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: primaryColor,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(loginOrnament),
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      50.spaceY,

                      Row(
                        spacing: 4,
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          Text(
                            "Register",
                            style: TextStyle(
                              fontSize: fontSizeTitle,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      24.spaceY,

                      Form(
                        key: formKey,
                        child: Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextField(
                              controller: fullnameC,
                              labelText: 'Nama Lengkap',
                              hintText: "Nama Lengkap",
                              borderRadius: BorderRadius.circular(100),
                              fillColor: Colors.transparent,
                              emptyText: "Nama Lengkap wajib di isi",
                              textInputType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                            ),
                            CustomTextField(
                              controller: emergencyContactC,
                              labelText: 'Nomor Telepon',
                              isPhoneNumber: true,
                              textInputType: TextInputType.phone,
                              hintText: "Nomor Telepon",
                              borderRadius: BorderRadius.circular(100),
                              fillColor: Colors.transparent,
                              emptyText: "Nomor Telepon wajib di isi",
                              textInputAction: TextInputAction.next,
                            ),
                            CustomTextField(
                              controller: passwordC,
                              labelText: "Kata Sandi",
                              isPassword: true,
                              hintText: "Kata Sandi",
                              borderRadius: BorderRadius.circular(100),
                              fillColor: Colors.transparent,
                              emptyText: "Kata Sandi tidak boleh kosong",
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                            ),
                            CustomTextField(
                              controller: passwordConfirmC,
                              labelText: "Konfirmasi Kata Sandi",
                              isPassword: true,
                              hintText: "Konfirmasi Kata Sandi",
                              fillColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              emptyText:
                                  "Konfirmasi Kata Sandi tidak boleh kosong",
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                            ),

                            12.spaceY,

                            CustomButton(
                              onTap: submitRegister,
                              isLoading:
                                  context
                                          .watch<RegisterNotifier>()
                                          .providerState ==
                                      ProviderState.loading
                                  ? true
                                  : false,
                              isBorder: false,
                              isBorderRadius: true,
                              sizeBorderRadius: 100,
                              isBoxShadow: false,
                              btnColor: ColorResources.white,
                              btnTxt: "Register",
                              loadingColor: primaryColor,
                              btnTextColor: ColorResources.black,
                            ),
                            20.spaceY,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
