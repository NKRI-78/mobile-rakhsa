import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';
import 'package:rakhsa/modules/auth/validator/auth_field.dart';
import 'package:rakhsa/modules/auth/validator/error_reason.dart';
import 'package:rakhsa/routes/routes_navigation.dart';

import 'package:rakhsa/misc/utils/color_resources.dart';

import 'package:rakhsa/misc/constants/theme.dart';

import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/modules/auth/widget/auth_text_field.dart';
import 'package:rakhsa/widgets/components/button/custom.dart';
import 'package:rakhsa/widgets/components/textinput/textfield.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: locator<AuthProvider>(),
      child: RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final _phoneFNode = FocusNode();
  final _passFNode = FocusNode();
  final _confirmPassFNode = FocusNode();

  final _errFields = <AuthField, ErrorReason>{};

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();

    _phoneFNode.dispose();
    _passFNode.dispose();
    _confirmPassFNode.dispose();

    super.dispose();
  }

  void _addErrField(AuthField field, ErrorReason reason) {
    _errFields[field] = reason;
  }

  void _removeErrField(AuthField field) {
    _errFields.remove(field);
  }

  String? _onValidateFullname(String? val) {
    final field = AuthField.fullname;
    if (val == null || val.isEmpty) {
      _addErrField(
        field,
        ErrorReason(
          title: "Nama Lengkap Kosong",
          message: "Harap mengisi nama lengkap.",
        ),
      );
      return "Nama Lengkap tidak boleh kosong.";
    }
    _removeErrField(field);
    return null;
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

  String? _onValidateConfirmPassword(String? val) {
    final field = AuthField.confirmPassword;
    final reason = ErrorReason();
    if (val == null || val.isEmpty) {
      _addErrField(
        field,
        reason.copyWith(
          title: "Password Kosong",
          message: "Harap mengisi password.",
        ),
      );
      return "Password tidak boleh kosong.";
    }
    if (val != _passController.text) {
      _addErrField(
        field,
        reason.copyWith(
          title: "Konfirmasi Password Tidak Sama",
          message: "Pastikan password dan konfirmasi password sesuai.",
        ),
      );
      return "Password tidak sama.";
    }
    _removeErrField(field);
    return null;
  }

  void _onRegisterUser(BuildContext c) async {
    if (_formKey.currentState!.validate()) {
      await c.read<AuthProvider>().register(
        fullname: _fullNameController.text,
        phone: PhoneNumberFormatter.unmask(_phoneController.text),
        password: _passController.text,
        onSuccess: () async {
          await StorageHelper.loadlocalSession();
          if (c.mounted) {
            c.pushNamedAndRemoveUntil(
              RoutesNavigation.dashboard,
              (route) => false,
              arguments: {"from_register": true},
            );
          }
        },
        onError: (message, errorCode) async {
          _phoneFNode.unfocus();
          _passFNode.unfocus();
          _confirmPassFNode.unfocus();

          final userAlreadyExists = errorCode == "User already exist";
          AppDialog.error(
            c: c,
            title: userAlreadyExists ? "Akun Sudah Terdaftar" : null,
            message: message ?? "-",
            buildActions: (dc) => [
              if (userAlreadyExists) ...[
                DialogActionButton(
                  label: "Masuk",
                  primary: true,
                  onTap: () async {
                    dc.pop();
                    await Future.delayed(Duration(milliseconds: 230));
                    if (mounted) {
                      context.pushNamed(RoutesNavigation.login);
                    }
                  },
                ),
              ] else ...[
                DialogActionButton(
                  label: "Cek Kembali",
                  primary: true,
                  onTap: c.pop,
                ),
              ],
            ],
          );
        },
      );
    } else {
      final fullnameErr = _errFields[AuthField.fullname];
      final phoneErr = _errFields[AuthField.phone];
      final passErr = _errFields[AuthField.password];
      final confirmPassErr = _errFields[AuthField.confirmPassword];

      final err = fullnameErr ?? phoneErr ?? passErr ?? confirmPassErr;

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
                        key: _formKey,
                        child: Column(
                          // spacing: 16,Au
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              label: "Nama Lengkap",
                              hintText: "Masukan nama lengkap Anda",
                              controller: _fullNameController,
                              fullname: true,
                              onFieldSubmitted: (_) =>
                                  _phoneFNode.requestFocus(),
                              validator: _onValidateFullname,
                            ),

                            16.spaceY,

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
                              onFieldSubmitted: (_) =>
                                  _confirmPassFNode.requestFocus(),
                              validator: _onValidatePassword,
                            ),

                            16.spaceY,

                            AuthTextField(
                              password: true,
                              label: "Konfirmasi Password",
                              hintText: "Ketik ulang password",
                              controller: _confirmPassController,
                              focusNode: _confirmPassFNode,
                              onFieldSubmitted: (_) => context.unfocus(),
                              validator: _onValidateConfirmPassword,
                            ),

                            24.spaceY,

                            Consumer<AuthProvider>(
                              builder: (context, state, child) {
                                return CustomButton(
                                  isLoading: state.registerLoading,
                                  isBorder: false,
                                  isBorderRadius: true,
                                  sizeBorderRadius: 100,
                                  isBoxShadow: false,
                                  btnColor: ColorResources.white,
                                  btnTxt: "Register",
                                  loadingColor: primaryColor,
                                  btnTextColor: ColorResources.black,
                                  onTap: () => _onRegisterUser(context),
                                );
                              },
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
