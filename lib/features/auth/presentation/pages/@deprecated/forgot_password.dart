// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:rakhsa/common/constants/theme.dart';

// import 'package:rakhsa/common/helpers/enum.dart';
// import 'package:rakhsa/common/helpers/snackbar.dart';

// import 'package:rakhsa/common/utils/color_resources.dart';
// import 'package:rakhsa/common/utils/custom_themes.dart';
// import 'package:rakhsa/common/utils/dimensions.dart';

// import 'package:rakhsa/features/auth/presentation/provider/forgot_password_notifier.dart';

// import 'package:rakhsa/shared/basewidgets/button/custom.dart';
// import 'package:rakhsa/shared/basewidgets/textinput/textfield.dart';

// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({super.key});

//   @override
//   State<ForgotPasswordPage> createState() => ForgotPasswordPageState();
// }

// class ForgotPasswordPageState extends State<ForgotPasswordPage> {

//   GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   late ForgotPasswordNotifier forgotPasswordNotifier;

//   late TextEditingController emailC; 
//   late TextEditingController passwordC; 
//   late TextEditingController passwordNewC;

//   Future<void> submit() async {
//     if (emailC.text.isEmpty) {
//       ShowSnackbar.snackbarErr("Alamat E-mail tidak boleh kosong");
//       return;
//     } 

//     if (passwordC.text.isEmpty) {
//       ShowSnackbar.snackbarErr("Kata sandi lama tidak boleh kosong");
//       return;
//     }

//     if(passwordNewC.text.isEmpty) {
//       ShowSnackbar.snackbarErr("Kata sandi baru tidak boleh kosong");
//       return;
//     }

//     await forgotPasswordNotifier.forgotPassword(
//       context: context,
//       email: emailC.text, 
//       oldPassword: passwordC.text, 
//       newPassword: passwordNewC.text
//     );
    
//   }

//   @override 
//   void initState() {
//     super.initState();

//     forgotPasswordNotifier = context.read<ForgotPasswordNotifier>();

//     emailC = TextEditingController();
//     passwordC = TextEditingController();
//     passwordNewC = TextEditingController();
//   }

//   @override 
//   void dispose() {
//     emailC.dispose();
//     passwordC.dispose();
//     passwordNewC.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryColor,
//       body: SafeArea(
//         child: Container(
//           padding: const EdgeInsets.only(
//             top: 16.0, 
//             left: 20.0,
//             right: 20.0,
//             bottom: 16.0
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [

//                 Container(
//                   width: double.infinity,
//                   height: MediaQuery.of(context).size.height * 0.3,
//                   decoration: const BoxDecoration(
//                     image: DecorationImage(
//                       fit: BoxFit.fill,
//                       image: AssetImage('assets/images/login-ornament.png')
//                     )
//                   ),
//                 ),

//                 Image.asset("assets/images/logo.png",
//                   width: 230.0,
//                   fit: BoxFit.scaleDown,
//                 ),

//                 const SizedBox(height: 80.0),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [

//                     Text("Lupa kata sandi",
//                       style: robotoRegular.copyWith(
//                         fontSize: Dimensions.fontSizeLarge,
//                         fontWeight: FontWeight.bold,
//                         color: ColorResources.white
//                       ),
//                     ),
          
//                   ],
//                 ),

//                 const SizedBox(height: 20.0),

//                 Form(
//                   key: formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
                
//                       Container(
//                         margin: const EdgeInsets.only(
//                           left: 8.0
//                         ),
//                         child: Text("Email terdaftar",
//                           style: robotoRegular.copyWith(
//                             fontSize: Dimensions.fontSizeSmall,
//                             color: ColorResources.white
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 8.0),
                
//                       CustomTextField(
//                         controller: emailC,
//                         labelText: "",
//                         isEmail: true,
//                         cursorColor: ColorResources.white,
//                         onChanged: (p0) {},
//                         hintText: "",
//                         fillColor: Colors.transparent,
//                         textInputType: TextInputType.emailAddress,
//                         textInputAction: TextInputAction.next,
//                       ),

//                       const SizedBox(height: 15.0),

//                       Container(
//                         margin: const EdgeInsets.only(
//                           left: 8.0
//                         ),
//                         child: Text("Kata sandi lama",
//                           style: robotoRegular.copyWith(
//                             fontSize: Dimensions.fontSizeSmall,
//                             color: ColorResources.white
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 8.0),
                
//                       CustomTextField(
//                         controller: passwordC,
//                         labelText: "",
//                         isPassword: true,
//                         cursorColor: ColorResources.white,
//                         hintText: "",
//                         fillColor: Colors.transparent,
//                         textInputType: TextInputType.text,
//                         textInputAction: TextInputAction.done,
//                       ),

//                       const SizedBox(height: 8.0),

//                       Container(
//                         margin: const EdgeInsets.only(
//                           left: 8.0
//                         ),
//                         child: Text("Kata sandi baru",
//                           style: robotoRegular.copyWith(
//                             fontSize: Dimensions.fontSizeSmall,
//                             color: ColorResources.white
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 8.0),
                
//                       CustomTextField(
//                         controller: passwordNewC,
//                         labelText: "",
//                         isPassword: true,
//                         cursorColor: ColorResources.white,
//                         hintText: "",
//                         fillColor: Colors.transparent,
//                         textInputType: TextInputType.text,
//                         textInputAction: TextInputAction.done,
//                       ),

//                       const SizedBox(height: 20.0),

//                       CustomButton(
//                         onTap: submit,
//                         isLoading: context.watch<ForgotPasswordNotifier>().providerState == ProviderState.loading 
//                         ? true 
//                         : false,
//                         isBorder: false,
//                         isBorderRadius: true,
//                         isBoxShadow: false,
//                         btnTxt: "Submit",
//                         loadingColor: primaryColor,
//                         btnColor: ColorResources.white,
//                         btnTextColor: ColorResources.black,
//                       ),
                
//                     ],
//                   )
//                 )

//               ]
          
//             )
//           ),
//         ),
//       )
//     );
//   }
// }