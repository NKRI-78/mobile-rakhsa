import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';

import 'package:rakhsa/common/utils/color_resources.dart';

import 'package:rakhsa/common/constants/theme.dart';

import 'package:rakhsa/helper/extensions.dart';
import 'package:rakhsa/injection.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/modules/auth/widget/auth_text_field.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';
import 'package:rakhsa/shared/basewidgets/textinput/textfield.dart';

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
                        key: _formKey,
                        child: Column(
                          spacing: 16,
                          children: [
                            AuthTextField(
                              label: "Nama Lengkap",
                              hintText: "Masukan nama lengkap Anda",
                              controller: _fullNameController,
                              onFieldSubmitted: (_) =>
                                  _phoneFNode.requestFocus(),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Nama Lengkap tidak boleh kosong.";
                                }
                                return null;
                              },
                            ),
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
                                return null;
                              },
                            ),
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

                            8.spaceY,

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
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      void register() async {
                                        await context
                                            .read<AuthProvider>()
                                            .register(
                                              fullname:
                                                  _fullNameController.text,
                                              phone:
                                                  PhoneNumberFormatter.unmask(
                                                    _phoneController.text,
                                                  ),
                                              password: _passController.text,
                                              onSuccess: () {
                                                Navigator.of(
                                                  context,
                                                ).pushNamedAndRemoveUntil(
                                                  RoutesNavigation.dashboard,
                                                  (route) => false,
                                                );
                                              },
                                              onError: (code, message) {
                                                GeneralModal.error(
                                                  context,
                                                  message,
                                                  onReload: () {
                                                    context.pop();
                                                    register();
                                                  },
                                                );
                                              },
                                            );
                                      }

                                      register();
                                    }
                                  },
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
