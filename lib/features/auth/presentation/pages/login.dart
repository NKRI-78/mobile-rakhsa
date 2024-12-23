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
import 'package:rakhsa/features/auth/presentation/provider/update_is_loggedin_notifier.dart';

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
  late UpdateIsLoggedinNotifier updateIsLoggedinNotifier;

  late TextEditingController valC; 
  late TextEditingController passwordC; 

  FocusNode valFn = FocusNode();
  FocusNode passwordFn = FocusNode();

  void setStateObscure() {
    setState(() => isObscure = !isObscure);
  }

  Future<void> submitLogin() async {
    bool submissionValidation(BuildContext context, String email, String password) {
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


    String val = valC.text.trim();
    String pass = passwordC.text.trim();

    final bool isClear = submissionValidation(context, val, pass);

    if(isClear){
      await loginNotifier.login(
        value: val, 
        password: pass
      );
    }

    if(loginNotifier.message != "") {
      ShowSnackbar.snackbarErr(loginNotifier.message);
      return;
    } else {
      await updateIsLoggedinNotifier.updateIsLoggedIn(
        userId: loginNotifier.authModel.data!.user.id, 
        type: "login"
      );

      if(updateIsLoggedinNotifier.message != "") {
        ShowSnackbar.snackbarErr(updateIsLoggedinNotifier.message);
        return;
      }
    }
  }

  @override 
  void initState() {
    super.initState();

    valC = TextEditingController();
    passwordC = TextEditingController();

    loginNotifier = context.read<LoginNotifier>();
    updateIsLoggedinNotifier = context.read<UpdateIsLoggedinNotifier>();
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
                
                      CustomTextField(
                        controller: valC,
                        labelText: '',
                        isEmail: true,
                        cursorColor: ColorResources.white,
                        onChanged: (p0) {},
                        hintText: "",
                        fillColor: Colors.transparent,
                        emptyText: "Email wajib di isi",
                        textInputType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
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
                
                      CustomTextField(
                        controller: passwordC,
                        labelText: "",
                        isPassword: true,
                        cursorColor: ColorResources.white,
                        hintText: "",
                        fillColor: Colors.transparent,
                        emptyText: "Kata Sandi tidak boleh kosong",
                        textInputType: TextInputType.text,
                        textInputAction: TextInputAction.done,
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
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterPage()));
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