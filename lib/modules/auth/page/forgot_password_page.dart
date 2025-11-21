import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/formatters/text_field_formatter.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/modules/auth/validator/auth_field.dart';
import 'package:rakhsa/modules/auth/validator/error_reason.dart';
import 'package:rakhsa/modules/auth/widget/auth_text_field.dart';
import 'package:rakhsa/widgets/components/button/custom.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: locator<AuthProvider>(),
      child: ForgotPassworScreen(),
    );
  }
}

class ForgotPassworScreen extends StatefulWidget {
  const ForgotPassworScreen({super.key});

  @override
  State<ForgotPassworScreen> createState() => _ForgotPassworScreenState();
}

class _ForgotPassworScreenState extends State<ForgotPassworScreen> {
  final _phoneController = TextEditingController();
  final _newPassController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _newPassFNode = FocusNode();

  final _errFields = <AuthField, ErrorReason>{};

  @override
  void dispose() {
    _newPassFNode.dispose();
    _phoneController.dispose();
    _newPassController.dispose();
    super.dispose();
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

  void _onSubmitNewPassword(BuildContext c) async {
    final phone = PhoneNumberFormatter.unmask(_phoneController.text);

    if (_formKey.currentState!.validate()) {
      await c.read<AuthProvider>().forgotPassword(
        phone: phone,
        newPassword: _newPassController.text,
        onSuccess: () async {
          if (c.mounted) {
            await AppDialog.show(
              c: c,
              dismissible: false,
              content: DialogContent(
                title: "Password Diperbarui",
                message:
                    "Password Anda telah berhasil diubah. Silakan masuk kembali menggunakan password baru Anda.",
                buildActions: (c) {
                  return [
                    DialogActionButton(
                      label: "Login Kembali",
                      primary: true,
                      onTap: () => c.pop(true),
                    ),
                  ];
                },
              ),
            );
            await StorageHelper.write("phone_cache", phone);
            await Future.delayed(Duration(milliseconds: 100));

            // back kehalaman login harus true
            // jangan diganti false
            if (c.mounted) c.pop(true);
          }
        },
        onError: (message, errorCode) async {
          _newPassFNode.unfocus();
          final userNotFound = errorCode == "User not found";
          await AppDialog.error(
            c: c,
            title: userNotFound
                ? "Akun Belum Terdaftar"
                : "Gagal Mengganti Password",
            message: message ?? "-",
            buildActions: (c) {
              return [
                DialogActionButton(
                  label: "Coba Lagi",
                  primary: true,
                  onTap: () => c.pop(true),
                ),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.pop(false);
      },
      child: GestureDetector(
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
                              "Lupa Password",
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
                                onFieldSubmitted: (_) =>
                                    _newPassFNode.requestFocus(),
                                validator: _onValidatePhoneNumber,
                              ),

                              16.spaceY,

                              AuthTextField(
                                password: true,
                                label: "Password Baru",
                                hintText: "Masukan Password yang baru",
                                controller: _newPassController,
                                focusNode: _newPassFNode,
                                validator: _onValidatePassword,
                              ),

                              24.spaceY,

                              Consumer<AuthProvider>(
                                builder: (context, provider, child) {
                                  return CustomButton(
                                    isLoading: provider.forgotPassLoading,
                                    isBorder: false,
                                    isBorderRadius: true,
                                    sizeBorderRadius: 100,
                                    isBoxShadow: false,
                                    btnTxt: "Ganti Password",
                                    loadingColor: primaryColor,
                                    btnColor: ColorResources.white,
                                    btnTextColor: ColorResources.black,
                                    onTap: () => _onSubmitNewPassword(context),
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
      ),
    );
  }
}
