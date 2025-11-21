import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/injection.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';
import 'package:rakhsa/modules/auth/page/forgot_password_page.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/modules/auth/validator/auth_field.dart';
import 'package:rakhsa/modules/auth/validator/error_reason.dart';
import 'package:rakhsa/modules/auth/widget/auth_text_field.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/widgets/components/button/custom.dart';
import 'package:rakhsa/widgets/components/textinput/textfield.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: locator<AuthProvider>(),
      child: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _passController = TextEditingController();

  final _phoneFNode = FocusNode();
  final _passFNode = FocusNode();

  final _errFields = <AuthField, ErrorReason>{};

  @override
  void dispose() {
    _phoneController.dispose();
    _passController.dispose();
    _phoneFNode.dispose();
    _passFNode.dispose();
    super.dispose();
  }

  void _onNavigateToForgotPassword(BuildContext c) async {
    bool? successUpdate = await Navigator.of(c).push<bool?>(
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
    if (c.mounted) c.unfocus();
    if (successUpdate != null && successUpdate) {
      final phone = StorageHelper.read("phone_cache");
      if (phone != null) {
        _phoneController.text = phone;
        _passController.text = "";
        await Future.delayed(Duration(milliseconds: 100));
        if (mounted) _passFNode.requestFocus();
        await Future.delayed(Duration(milliseconds: 200));
        AppDialog.showToast(
          "Masuk menggunakan password baru Anda",
          length: Toast.LENGTH_LONG,
        );
      }
    }
  }

  void _addErrField(AuthField field, ErrorReason reason) {
    _errFields[field] = reason;
  }

  void _removeErrField(AuthField field) {
    _errFields.remove(field);
  }

  String? _onValidatePhoneNumber(String? val) {
    final field = AuthField.phone;
    final reason = ErrorReason();
    if (val == null || val.isEmpty) {
      _addErrField(
        field,
        reason.copyWith(
          title: "Nomor Telepon Kosong",
          message: "Harap mengisi nomor telepon.",
        ),
      );
      return "Nomor Telepon tidak boleh kosong.";
    }
    if (val.length < 10) {
      _addErrField(
        field,
        reason.copyWith(
          title: "Nomor Telepon Tidak Valid",
          message: "Nomor telepon minimal 10 digit angka.",
        ),
      );
      return "Nomor telepon minimal 10 digit angka.";
    }
    _removeErrField(field);
    return null;
  }

  String? _onValidatePassword(String? val) {
    final field = AuthField.password;
    if (val == null || val.isEmpty) {
      _addErrField(
        field,
        ErrorReason(
          title: "Password Kosong",
          message: "Harap mengisi password.",
        ),
      );
      return "Password tidak boleh kosong.";
    }
    _removeErrField(field);
    return null;
  }

  void _onLoginUser(BuildContext c) async {
    if (_formKey.currentState!.validate()) {
      await c.read<AuthProvider>().login(
        phone: PhoneNumberFormatter.unmask(_phoneController.text),
        password: _passController.text,
        onSuccess: () async {
          await StorageHelper.loadlocalSession();
          await StorageHelper.delete("phone_cache");
          if (c.mounted) {
            c.pushNamedAndRemoveUntil(
              RoutesNavigation.dashboard,
              (route) => false,
            );
          }
        },
        onError: (message, errorCode) async {
          _phoneFNode.unfocus();
          _passFNode.unfocus();

          final userNotFound = errorCode == "User not found";
          final wrongPassword = errorCode == "Credentials invalid";

          final title = userNotFound
              ? "Akun Belum Terdaftar"
              : wrongPassword
              ? "Password Salah"
              : "Terjadi Kesalahan";

          await AppDialog.error(
            c: c,
            title: title,
            message: message ?? "-",
            buildActions: (c) {
              return [
                if (userNotFound) ...[
                  DialogActionButton(label: "Tutup", onTap: c.pop),
                  DialogActionButton(
                    label: "Daftar Akun",
                    primary: true,
                    onTap: () async {
                      c.pop();
                      await Future.delayed(Duration(milliseconds: 230));
                      if (mounted) {
                        context.pushNamed(RoutesNavigation.register);
                      }
                    },
                  ),
                ] else ...[
                  DialogActionButton(
                    label: wrongPassword ? "Tutup" : "Cek Kembali",
                    primary: true,
                    onTap: c.pop,
                  ),
                ],
              ];
            },
          );
        },
      );
    } else {
      final phoneErr = _errFields[AuthField.phone];
      final passErr = _errFields[AuthField.password];

      final err = phoneErr ?? passErr;

      AppDialog.show(
        c: c,
        content: DialogContent(
          assetIcon: 'assets/images/ic-alert.png',
          title: err?.title ?? "Terjadi Kesalahan Form",
          message: err?.message ?? "Cek kembali data inputan Anda.",
          buildActions: (c) {
            return [
              DialogActionButton(label: "Periksa", primary: true, onTap: c.pop),
            ];
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
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
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              phone: true,
                              label: "Nomor Telepon",
                              hintText: "08** **** ****",
                              controller: _phoneController,
                              focusNode: _phoneFNode,
                              onFieldSubmitted: (_) =>
                                  _passFNode.requestFocus(),
                              validator: _onValidatePhoneNumber,
                            ),

                            6.spaceY,
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                "*Pastikan Nomor Telepon Anda terdaftar paket Roaming.",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                ),
                              ),
                            ),

                            16.spaceY,

                            AuthTextField(
                              password: true,
                              label: "Password",
                              hintText: "******",
                              controller: _passController,
                              focusNode: _passFNode,
                              validator: _onValidatePassword,
                            ),

                            8.spaceY,

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Bounce(
                                  scaleFactor: 0.98,
                                  onTap: () =>
                                      _onNavigateToForgotPassword(context),
                                  child: Container(
                                    height: kMinInteractiveDimension,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: 12),
                                    child: Text(
                                      "Lupa Password",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            8.spaceY,

                            Consumer<AuthProvider>(
                              builder: (context, provider, child) {
                                return CustomButton(
                                  isLoading: provider.loginLoading,
                                  isBorder: false,
                                  isBorderRadius: true,
                                  sizeBorderRadius: 100,
                                  isBoxShadow: false,
                                  btnTxt: "Masuk",
                                  loadingColor: primaryColor,
                                  btnColor: ColorResources.white,
                                  btnTextColor: ColorResources.black,
                                  onTap: () => _onLoginUser(context),
                                );
                              },
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
