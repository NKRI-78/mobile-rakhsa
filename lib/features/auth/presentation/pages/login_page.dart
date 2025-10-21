import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/provider/login_notifier.dart';
import 'package:rakhsa/helper/extensions.dart';

import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/shared/basewidgets/textinput/textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isObscure = false;

  late LoginNotifier loginNotifier;

  late TextEditingController valC;
  late TextEditingController passwordC;

  FocusNode valFn = FocusNode();
  FocusNode passwordFn = FocusNode();

  void setStateObscure() {
    setState(() => isObscure = !isObscure);
  }

  Future<void> submitLogin() async {
    bool submissionValidation(
      BuildContext context,
      String email,
      String password,
    ) {
      if (email.isEmpty) {
        ShowSnackbar.snackbarErr("Email tidak boleh kosong");
        valFn.requestFocus();
        return false;
      } else if (password.isEmpty) {
        ShowSnackbar.snackbarErr("Password tidak boleh kosong");
        passwordFn.requestFocus();
        return false;
      }
      return true;
    }

    String val = PhoneNumberFormatter.unmask(valC.text.trim());
    String pass = passwordC.text.trim();

    final bool isClear = submissionValidation(context, val, pass);

    log('phone = $val');
    log('pass = $pass');

    if (isClear) {
      await loginNotifier.login(value: val, password: pass);
    }

    if (loginNotifier.message != "") {
      ShowSnackbar.snackbarErr(loginNotifier.message);
      return;
    } else {
      // if (updateIsLoggedinNotifier.message != "") {
      //   ShowSnackbar.snackbarErr(updateIsLoggedinNotifier.message);
      //   return;
      // }
    }
  }

  @override
  void initState() {
    super.initState();

    valC = TextEditingController();
    passwordC = TextEditingController();

    loginNotifier = context.read<LoginNotifier>();
    // updateIsLoggedinNotifier = context.read<UpdateIsLoggedinNotifier>();
  }

  @override
  void dispose() {
    valC.dispose();
    passwordC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.unfocus(),
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
                      image: AssetImage(AssetSource.loginOrnament),
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                            "Login",
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Nomor HP",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: ColorResources.white,
                                ),
                              ),
                            ),

                            8.spaceY,

                            CustomTextField(
                              controller: valC,
                              cursorColor: ColorResources.white,
                              onChanged: (p0) {},
                              isPhoneNumber: true,
                              borderRadius: BorderRadius.circular(100),
                              hintText: "08** *** ***",
                              fillColor: Colors.transparent,
                              emptyText: "No Telp wajib di isi",
                              textInputType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),

                            16.spaceY,

                            Container(
                              margin: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Password",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: ColorResources.white,
                                ),
                              ),
                            ),

                            8.spaceY,

                            CustomTextField(
                              controller: passwordC,
                              isPassword: true,
                              cursorColor: ColorResources.white,
                              hintText: "*********",
                              borderRadius: BorderRadius.circular(100),
                              fillColor: Colors.transparent,
                              emptyText: "Kata Sandi tidak boleh kosong",
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                            ),

                            24.spaceY,

                            CustomButton(
                              onTap: submitLogin,
                              isLoading:
                                  context
                                          .watch<LoginNotifier>()
                                          .providerState ==
                                      ProviderState.loading
                                  ? true
                                  : false,
                              isBorder: false,
                              isBorderRadius: true,
                              sizeBorderRadius: 100,
                              isBoxShadow: false,
                              btnTxt: "Masuk",
                              loadingColor: primaryColor,
                              btnColor: ColorResources.white,
                              btnTextColor: ColorResources.black,
                            ),
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
