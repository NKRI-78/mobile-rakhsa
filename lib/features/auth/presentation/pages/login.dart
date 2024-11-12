import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController emailC; 
  late TextEditingController passwordC; 

  @override 
  void initState() {
    super.initState();

    emailC = TextEditingController();
    passwordC = TextEditingController();
  }

  @override 
  void dispose() {
    emailC.dispose();
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
                          controller: emailC,
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

                      const SizedBox(height: 20.0),

                      CustomButton(
                        onTap: () {},
                        isBorder: false,
                        isBorderRadius: true,
                        isBoxShadow: false,
                        btnColor: ColorResources.white,
                        btnTxt: "Masuk",
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
                        child: Text("BUAT AKUN BARU",
                          style: robotoRegular.copyWith(
                            color: const Color(0XFFFEE717),
                            fontWeight: FontWeight.bold
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