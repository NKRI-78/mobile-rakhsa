import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/helpers/storage.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';
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

  void _onRegisterUser(BuildContext c) async {
    Future registerUser() async {
      await c.read<AuthProvider>().register(
        fullname: _fullNameController.text,
        phone: PhoneNumberFormatter.unmask(_phoneController.text),
        password: _passController.text,
        onSuccess: () async {
          await StorageHelper.loadlocalSession();
          if (c.mounted) {
            Navigator.of(c).pushNamedAndRemoveUntil(
              RoutesNavigation.dashboard,
              (route) => false,
              arguments: {"from_register": true},
            );
          }
        },
        onError: (eCode, code, m) async {
          final userAlreadyExists = eCode == "User already exist";
          bool? readyExists = await AppDialog.error(
            c: c,
            title: eCode == "User already exist"
                ? "Akun Sudah Terdaftar"
                : null,
            message: m,
            actions: [
              if (userAlreadyExists) ...[
                DialogActionButton(
                  label: "Masuk",
                  primary: true,
                  onTap: () => context.pop(true),
                ),
              ] else ...[
                DialogActionButton(
                  label: "Cek Kembali",
                  primary: true,
                  onTap: () => context.pop(false),
                ),
              ],
            ],
          );
          if (readyExists != null && readyExists) {
            await Future.delayed(Duration(milliseconds: 200));
            if (mounted) {
              context.pushNamed(RoutesNavigation.login);
            }
          }
        },
      );
    }

    if (_formKey.currentState!.validate()) registerUser();
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
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Nama Lengkap tidak boleh kosong.";
                                }
                                return null;
                              },
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
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Nomor Telepon tidak boleh kosong.";
                                }
                                if (val.length < 10) {
                                  return "Nomor Telepon minimal 10 digit angka.";
                                }
                                return null;
                              },
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
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Password tidak boleh kosong.";
                                }
                                return null;
                              },
                            ),

                            16.spaceY,

                            AuthTextField(
                              password: true,
                              label: "Konfirmasi Password",
                              hintText: "Ketik ulang password",
                              controller: _confirmPassController,
                              focusNode: _confirmPassFNode,
                              onFieldSubmitted: (_) => context.unfocus(),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Password tidak boleh kosong.";
                                }
                                if (val != _passController.text) {
                                  return "Password tidak sama.";
                                }
                                return null;
                              },
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
