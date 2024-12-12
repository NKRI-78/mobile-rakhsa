import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';

import 'package:rakhsa/features/auth/presentation/provider/register_notifier.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/shared/basewidgets/textinput/textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late RegisterNotifier registerNotifier;

  late TextEditingController fullnameC;
  late TextEditingController emailC;
  late TextEditingController phoneC;
  late TextEditingController passportC;
  late TextEditingController emergencyContactC;
  late TextEditingController passwordC;
  late TextEditingController passwordConfirmC;

  Future<void> submitRegister() async {
    bool submissionValidation(
    BuildContext context,
    String fullname,
    String phone,
    String email,
    String passport,
    String emergencyContact,
    String password,
    String confirmPassword,
  ) {
    if (fullname.isEmpty) {
      ShowSnackbar.snackbarErr("Nama Lengkap tidak boleh kosong");
      return false;
    } else if (phone.isEmpty) {
      ShowSnackbar.snackbarErr("No Telepon tidak boleh kosong");
      return false;
    } else if (email.isEmpty) {
      ShowSnackbar.snackbarErr("Email tidak boleh kosong");
      return false;
    } else if (!email.isValidEmail()) {
      ShowSnackbar.snackbarErr("Email tidak valid");
      return false;
    } else if (passport.isEmpty) {
      ShowSnackbar.snackbarErr("Passport tidak boleh kosong");
      return false;
    } else if(emergencyContact.isEmpty) {
      ShowSnackbar.snackbarErr("Nomor Darurat tidak boleh kosong");
    } else if (password.isEmpty) {
      ShowSnackbar.snackbarErr("Password tidak boleh kosong");
      return false;
    } else if (confirmPassword.isEmpty) {
      ShowSnackbar.snackbarErr("Password Konfirmasi tidak boleh kosong");
      return false;
    } else if (password != confirmPassword) {
      ShowSnackbar.snackbarErr("Password tidak sama");
      return false;
    } else if (confirmPassword != password) {
      ShowSnackbar.snackbarErr("Password tidak sama");
      return false;
    }
    return true;
  }

    String fullname = fullnameC.text.trim();
    String email = emailC.text.trim();
    String phone = phoneC.text.trim();
    String passport = passportC.text.trim();
    String emergencyContact = emergencyContactC.text.trim();
    String password = passwordC.text.trim();
    String passConfirm = passwordConfirmC.text.trim();

    final isClear = submissionValidation(
      context,
      fullname,
      phone,
      email,
      passport,
      emergencyContact,
      password,
      passConfirm
    );
    
    if(isClear) {
      await registerNotifier.register(
        fullname: fullname,
        email: email,
        phone: phone,
        passport: passport,
        emergencyContact: emergencyContact,
        password: password,
      );
    }
    
    if(registerNotifier.message != "") {
      ShowSnackbar.snackbarErr(registerNotifier.message);
      return;
    }

  }

  @override 
  void initState() {
    super.initState();

    fullnameC = TextEditingController();
    emailC = TextEditingController();
    phoneC = TextEditingController();
    passportC = TextEditingController();
    emergencyContactC = TextEditingController();
    passwordC = TextEditingController();
    passwordConfirmC = TextEditingController();

    registerNotifier = context.read<RegisterNotifier>();
  }

  @override 
  void dispose() {
    fullnameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    passportC.dispose();
    emergencyContactC.dispose();
    passwordC.dispose();
    passwordConfirmC.dispose();

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
                          image: AssetImage(loginOrnament)
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
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Image.asset(
                            "assets/images/forward.png"
                          ),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child:CustomTextField(
                          controller: fullnameC,
                          labelText: 'Nama Lengkap',
                          isName: false,
                          isCapital: true,
                          hintText: "Nama Lengkap",
                          fillColor: Colors.transparent,
                          emptyText: "Nama Lengkap wajib di isi",
                          textInputType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomTextField(
                          controller: emailC,
                          labelText: 'Alamat Email',
                          isEmail: true,
                          hintText: "Alamat Email",
                          fillColor: Colors.transparent,
                          emptyText: "Email wajib di isi",
                          textInputType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomTextField(
                          controller: phoneC,
                          labelText: 'Nomor Handphone',
                          isPhoneNumber: true,
                          maxLength: 13,
                          hintText: "Nomer Handphone",
                          fillColor: Colors.transparent,
                          emptyText: "Nomer Handphone wajib di isi",
                          textInputType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomTextField(
                          controller: passportC,
                          labelText: "Nomor Passport",
                          isPhoneNumber: false,
                          isAllowedSymbol: true,
                          maxLength: 8,
                          hintText: "Nomor Passport",
                          fillColor: Colors.transparent,
                          emptyText: "Nomor Passport wajib di isi",
                          textInputType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomTextField(
                          controller: emergencyContactC,
                          labelText: 'Nomor Darurat',
                          isPhoneNumber: true,
                          maxLength: 13,
                          hintText: "Nomer Darurat",
                          fillColor: Colors.transparent,
                          emptyText: "Nomer Darurat wajib di isi",
                          textInputType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomTextField(
                          controller: passwordC,
                          labelText: "Kata Sandi",
                          isPassword: true,
                          hintText: "Kata Sandi",
                          fillColor: Colors.transparent,
                          emptyText: "Kata Sandi tidak boleh kosong",
                          textInputType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomTextField(
                          controller: passwordConfirmC,
                          labelText: "Konfirmasi Kata Sandi",
                          isPassword: true,
                          hintText: "Konfirmasi Kata Sandi",
                          fillColor: Colors.transparent,
                          emptyText: "Konfirmasi Kata Sandi tidak boleh kosong",
                          textInputType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomButton(
                        onTap: submitRegister,
                        isLoading: context.watch<RegisterNotifier>().providerState == ProviderState.loading 
                        ? true 
                        : false,
                        isBorder: false,
                        isBorderRadius: true,
                        isBoxShadow: false,
                        btnColor: ColorResources.white,
                        btnTxt: "Register",
                        loadingColor: primaryColor,
                        btnTextColor: ColorResources.black,
                      ),

                      const SizedBox(height: 20.0),

                      // Row(
                      //   mainAxisSize: MainAxisSize.max,
                      //   children: [

                      //     const Expanded(
                      //       flex: 3,
                      //       child: Divider()
                      //     ),

                      //     Expanded(
                      //       child: Center(
                      //         child: Text("Atau",
                      //           style: robotoRegular.copyWith(
                      //             fontSize: Dimensions.fontSizeSmall,
                      //             color: ColorResources.white
                      //           ),
                      //         )
                      //       )
                      //     ),

                      //     const Expanded(
                      //       flex: 3,
                      //       child: Divider()
                      //     ),

                      //   ],
                      // ),
                      
                      // const SizedBox(height: 20.0),

                      // CustomButton(
                      //   onTap: () {},
                      //   isLoading: context.watch<LoginNotifier>().providerState == ProviderState.loading 
                      //   ? true 
                      //   : false,
                      //   isBorder: false,
                      //   isBorderRadius: true,
                      //   isBoxShadow: false,
                      //   btnColor: ColorResources.white,
                      //   btnTxt: "Sign In With Google",
                      //   btnTextColor: ColorResources.black,
                      // ),
                
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