import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';

import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/modules/auth/widget/auth_text_field.dart';

import 'package:rakhsa/widgets/components/button/custom.dart';
import 'package:rakhsa/widgets/components/textinput/textfield.dart';
import 'package:rakhsa/widgets/dialog/app_dialog.dart';

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

  @override
  void dispose() {
    _phoneController.dispose();
    _passController.dispose();
    _phoneFNode.dispose();
    _passFNode.dispose();
    super.dispose();
  }

  void _onLoginUser(BuildContext c) async {
    Future loginUser() async {
      await c.read<AuthProvider>().login(
        phone: PhoneNumberFormatter.unmask(_phoneController.text),
        password: _passController.text,
        onSuccess: () {
          Navigator.of(c).pushNamedAndRemoveUntil(
            RoutesNavigation.dashboard,
            (route) => false,
          );
        },
        onError: (errorCode, code, message) async {
          await AppDialog.error(
            c: c,
            title: errorCode == "User not found"
                ? "Akun Belum Terdaftar"
                : "Password Salah",
            message: message,
          );
          _phoneFNode.unfocus();
          _passFNode.unfocus();
        },
      );
    }

    if (_formKey.currentState!.validate()) await loginUser();
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
                        key: _formKey,
                        child: Column(
                          spacing: 16,
                          children: [
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

                            AuthTextField(
                              password: true,
                              label: "Password",
                              hintText: "******",
                              controller: _passController,
                              focusNode: _passFNode,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Password tidak boleh kosong.";
                                }
                                return null;
                              },
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
