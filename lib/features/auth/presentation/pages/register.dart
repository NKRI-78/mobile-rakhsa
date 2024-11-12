import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rakhsa/common/constants/theme.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/shared/basewidgets/textinput/textfield.dart';

part '../widgets/register/_input_fullname.dart';
part '../widgets/register/_input_email.dart';
part '../widgets/register/_input_number.dart';
part '../widgets/register/_input_passport.dart';
part '../widgets/register/_input_number_urgent.dart';
part '../widgets/register/_field_confirm_password.dart';
part '../widgets/register/_field_password.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {

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
                Stack(
                  fit: StackFit.loose,
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(loginOrnamen)
                        )
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.asset(
                          "assets/images/signup-icon.png"
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Image.asset(
                          "assets/images/forward.png"
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Registrasi",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.paddingSizeLarge,
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: _InputFullname(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: InputEmail(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: InputNumber(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: InputPassport(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: InputNumberUrgent(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: _FieldPassword(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: _FieldConfirmPassword(),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomButton(
                        onTap: () {},
                        isBorder: false,
                        isBorderRadius: true,
                        isBoxShadow: false,
                        btnColor: ColorResources.white,
                        btnTxt: "Register",
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

                      CustomButton(
                        onTap: () {},
                        isBorder: false,
                        isBorderRadius: true,
                        isBoxShadow: false,
                        btnColor: ColorResources.white,
                        btnTxt: "Sign In With Google",
                        btnTextColor: ColorResources.black,
                      ),

                
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