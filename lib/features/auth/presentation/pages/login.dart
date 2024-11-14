import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/auth/presentation/pages/register.dart';

import 'package:rakhsa/features/auth/presentation/provider/login_notifier.dart';

import 'package:rakhsa/shared/basewidgets/button/custom.dart';

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

  void setStateObscure() {
    setState(() => isObscure = !isObscure);
  }

  Future<void> submitLogin() async {
    String val = valC.text;
    String password = passwordC.text;

    if(val.isEmpty) { 
      ShowSnackbar.snackbarErr("Field E-mail / Nomor Hp is required");
      return;
    }

    if(password.isEmpty) {
      ShowSnackbar.snackbarErr("Field Password is required");
      return;
    }

    if(password.isEmpty) return;

    await loginNotifier.login(
      value: val, 
      password: password
    );

    if(loginNotifier.message != "") {
      ShowSnackbar.snackbarErr(loginNotifier.message);
      return;
    }
  }

  @override 
  void initState() {
    super.initState();

    valC = TextEditingController();
    passwordC = TextEditingController();

    loginNotifier = context.read<LoginNotifier>();
  }

  @override 
  void dispose() {
    valC.dispose();
    passwordC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(
            top: 16.0, 
            left: 20.0,
            right: 20.0,
            bottom: 16.0
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/images/login-ornament.png')
                    )
                  ),
                ),

                Image.asset("assets/images/logo.png",
                  width: 230.0,
                  fit: BoxFit.scaleDown,
                ),

                const SizedBox(height: 80.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    Text("Login",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: ColorResources.white
                      ),
                    ),
          
                  ],
                ),

                const SizedBox(height: 10.0),

                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                
                      Container(
                        margin: const EdgeInsets.only(
                          left: 8.0
                        ),
                        child: Text("Email/Nomor HP",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: ColorResources.white
                          ),
                        ),
                      ),

                      const SizedBox(height: 8.0),
                
                      SizedBox(
                        height: 40.0,
                        child: TextField(
                          controller: valC,
                          cursorColor: ColorResources.white,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: ColorResources.white
                          ),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: ColorResources.transparent,
                            contentPadding: EdgeInsets.only(
                              top: 16.0,
                              left: 12.0,
                              right: 12.0,
                              bottom: 48.0
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0)
                              ),
                              borderSide: BorderSide(
                                color: ColorResources.white,
                              )
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0)
                              ),
                              borderSide: BorderSide(
                                color: ColorResources.white
                              )
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0)
                              ),
                              borderSide: BorderSide(
                                color: ColorResources.white
                              )
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15.0),

                      Container(
                        margin: const EdgeInsets.only(
                          left: 8.0
                        ),
                        child: Text("Password",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: ColorResources.white
                          ),
                        ),
                      ),

                      const SizedBox(height: 8.0),
                
                      SizedBox(
                        height: 40.0,
                        child: TextField(
                          controller: passwordC,
                          cursorColor: ColorResources.white,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: ColorResources.white
                          ),
                          obscureText: isObscure,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: ColorResources.transparent,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setStateObscure();
                              },
                              child: isObscure 
                            ? const Icon(
                                Icons.visibility,
                                color: ColorResources.white,
                              ) 
                            : const Icon(Icons.visibility_off,
                                color: ColorResources.white,
                              )
                            ),
                            contentPadding: const EdgeInsets.only(
                              top: 16.0,
                              left: 12.0,
                              right: 12.0,
                              bottom: 48.0
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0)
                              ),
                              borderSide: BorderSide(
                                color: ColorResources.white,
                              )
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0)
                              ),
                              borderSide: BorderSide(
                                color: ColorResources.white
                              )
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0)
                              ),
                              borderSide: BorderSide(
                                color: ColorResources.white
                              )
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      CustomButton(
                        onTap: submitLogin,
                        isLoading: context.watch<LoginNotifier>().providerState == ProviderState.loading 
                        ? true 
                        : false,
                        isBorder: false,
                        isBorderRadius: true,
                        isBoxShadow: false,
                        btnTxt: "Masuk",
                        loadingColor: primaryColor,
                        btnColor: ColorResources.white,
                        btnTextColor: ColorResources.black,
                      ),

                      const SizedBox(height: 20.0),

                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [

                          const Expanded(
                            flex: 3,
                            child: Divider()
                          ),

                          Expanded(
                            child: Center(
                              child: Text("Atau",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: ColorResources.white
                                ),
                              )
                            )
                          ),

                          const Expanded(
                            flex: 3,
                            child: Divider()
                          ),

                        ],
                      ),
                      
                      const SizedBox(height: 20.0),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return const RegisterPage();
                              },
                            ));
                          },
                          child: Text("BUAT AKUN BARU",
                            style: robotoRegular.copyWith(
                              color: const Color(0XFFFEE717),
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      )

                
                    ],
                  )
                )

              ]
          
            )
          ),
        ),
      )
    );
  }
}