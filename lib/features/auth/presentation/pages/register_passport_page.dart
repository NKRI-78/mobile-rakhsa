// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rakhsa/common/constants/theme.dart';
// import 'package:rakhsa/common/helpers/snackbar.dart';
// import 'package:rakhsa/common/routes/routes_navigation.dart';
// import 'package:rakhsa/common/utils/color_resources.dart';
// import 'package:rakhsa/common/utils/custom_themes.dart';
// import 'package:rakhsa/common/utils/dimensions.dart';
// import 'package:rakhsa/features/auth/presentation/provider/passport_scanner_notifier.dart';
// import 'package:rakhsa/shared/basewidgets/button/custom.dart';
// import 'package:rakhsa/shared/basewidgets/textinput/textfield.dart';

// class RegisterPassportPage extends StatefulWidget {
//   const RegisterPassportPage({super.key});

//   @override
//   State<RegisterPassportPage> createState() => _RegisterPassportPageState();
// }

// class _RegisterPassportPageState extends State<RegisterPassportPage> {
//   // data controller
//   late TextEditingController countryCodeC;
//   late TextEditingController passportNumberC;
//   late TextEditingController fullNameC;
//   late TextEditingController nationalityC;
//   late TextEditingController placeOfBirthC;
//   late TextEditingController dateOfBirthC;
//   late TextEditingController genderC;
//   late TextEditingController dateOfIssueC;
//   late TextEditingController dateOfExpiryC;
//   late TextEditingController registrationNumberC;
//   late TextEditingController issuingAuthorityC;
//   late TextEditingController mrzCodeC;

//   // form key
//   final formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     countryCodeC = TextEditingController();
//     fullNameC = TextEditingController();
//     passportNumberC = TextEditingController();
//     nationalityC = TextEditingController();
//     placeOfBirthC = TextEditingController();
//     dateOfBirthC = TextEditingController();
//     genderC = TextEditingController();
//     dateOfIssueC = TextEditingController();
//     dateOfExpiryC = TextEditingController();
//     registrationNumberC = TextEditingController();
//     issuingAuthorityC = TextEditingController();
//     mrzCodeC = TextEditingController();
//   }

//   @override
//   void dispose() {
//     countryCodeC.dispose();
//     passportNumberC.dispose();
//     fullNameC.dispose();
//     nationalityC.dispose();
//     placeOfBirthC.dispose();
//     dateOfBirthC.dispose();
//     genderC.dispose();
//     dateOfIssueC.dispose();
//     dateOfExpiryC.dispose();
//     registrationNumberC.dispose();
//     issuingAuthorityC.dispose();
//     mrzCodeC.dispose();
//     super.dispose();
//   }

//   bool get formIsValidate {
//     final eContryCode = countryCodeC.text.isNotEmpty;
//     final ePassportNumber = passportNumberC.text.isNotEmpty;
//     final eFullName = fullNameC.text.isNotEmpty;
//     final eNationality = nationalityC.text.isNotEmpty;
//     final ePlaceOfBirth = placeOfBirthC.text.isNotEmpty;
//     final eDateOfBirth = dateOfBirthC.text.isNotEmpty;
//     final eGender = genderC.text.isNotEmpty;
//     final eDateOfIssue = dateOfIssueC.text.isNotEmpty;
//     final eDateOfExpiry = dateOfExpiryC.text.isNotEmpty;
//     final eRegistrationNumber = registrationNumberC.text.isNotEmpty;
//     final eIssuingAuthority = issuingAuthorityC.text.isNotEmpty;
//     final eMrzCode = mrzCodeC.text.isNotEmpty;

//     return eContryCode &&
//         ePassportNumber &&
//         eFullName &&
//         eNationality &&
//         ePlaceOfBirth &&
//         eDateOfBirth &&
//         eGender &&
//         eDateOfIssue &&
//         eDateOfExpiry &&
//         eRegistrationNumber &&
//         eIssuingAuthority &&
//         eMrzCode;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryColor,
//       body: SafeArea(
//         child: Container(
//           padding: const EdgeInsets.only(
//               top: 16.0, left: 20.0, right: 20.0, bottom: 16.0),
//           child: SingleChildScrollView(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                 Stack(
//                   fit: StackFit.loose,
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       height: MediaQuery.of(context).size.height * 0.2,
//                       decoration: const BoxDecoration(
//                           image: DecorationImage(
//                               fit: BoxFit.fill,
//                               image: AssetImage(loginOrnament))),
//                     ),
//                     Align(
//                       alignment: Alignment.center,
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 10),
//                         child: Image.asset("assets/images/signup-icon.png"),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.bottomLeft,
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 50),
//                           child: Image.asset("assets/images/forward.png"),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Input Passpor",
//                       style: robotoRegular.copyWith(
//                           fontSize: Dimensions.paddingSizeLarge,
//                           fontWeight: FontWeight.bold,
//                           color: ColorResources.white),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10.0),

//                 // form
//                 Form(
//                     key: formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: CustomTextField(
//                             controller: countryCodeC,
//                             labelText: 'Kode Negara',
//                             isEmail: true,
//                             hintText: "Kode Negara",
//                             fillColor: Colors.transparent,
//                             emptyText: "Kode Negara wajib di isi",
//                             textInputType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: CustomTextField(
//                             controller: passportNumberC,
//                             labelText: 'No Passport',
//                             isEmail: true,
//                             hintText: "No Passport",
//                             fillColor: Colors.transparent,
//                             emptyText: "No Passport wajib di isi",
//                             textInputType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: CustomTextField(
//                             controller: fullNameC,
//                             labelText: 'Nama Lengkap',
//                             isEmail: true,
//                             hintText: "Nama Lengkap",
//                             fillColor: Colors.transparent,
//                             emptyText: "Nama Lengkap wajib di isi",
//                             textInputType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: CustomTextField(
//                             controller: nationalityC,
//                             labelText: 'Kewarganegaraan',
//                             isEmail: true,
//                             hintText: "Kewarganegaraan",
//                             fillColor: Colors.transparent,
//                             emptyText: "Kewarganegaraan wajib di isi",
//                             textInputType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: CustomTextField(
//                             controller: placeOfBirthC,
//                             labelText: 'Tempat Lahir',
//                             isEmail: true,
//                             hintText: "Tempat Lahir",
//                             fillColor: Colors.transparent,
//                             emptyText: "Tempat Lahir wajib di isi",
//                             textInputType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: CustomTextField(
//                             controller: genderC,
//                             labelText: 'Gender',
//                             isEmail: true,
//                             hintText: "Gender",
//                             fillColor: Colors.transparent,
//                             emptyText: "Gender wajib di isi",
//                             textInputType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: CustomTextField(
//                             controller: dateOfIssueC,
//                             labelText: 'Tanggal Penerbitan',
//                             isEmail: true,
//                             hintText: "Tanggal Penerbitan",
//                             fillColor: Colors.transparent,
//                             emptyText: "Tanggal Penerbitan wajib di isi",
//                             textInputType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: CustomTextField(
//                             controller: dateOfExpiryC,
//                             labelText: 'Tanggal Kadaluarsa',
//                             isEmail: true,
//                             hintText: "Tanggal Kadaluarsa",
//                             fillColor: Colors.transparent,
//                             emptyText: "Tanggal Kadaluarsa wajib di isi",
//                             textInputType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: CustomTextField(
//                             controller: registrationNumberC,
//                             labelText: 'Nomor Registrasi',
//                             isEmail: true,
//                             hintText: "Nomor Registrasi",
//                             fillColor: Colors.transparent,
//                             emptyText: "Nomor Registrasi wajib di isi",
//                             textInputType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: CustomTextField(
//                             controller: issuingAuthorityC,
//                             labelText: 'Kantor yang Mengeluarkan',
//                             isEmail: true,
//                             hintText: "Kantor yang Mengeluarkan",
//                             fillColor: Colors.transparent,
//                             emptyText: "Kantor yang Mengeluarkan wajib di isi",
//                             textInputType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: CustomTextField(
//                             controller: mrzCodeC,
//                             labelText: 'Kode MRZ',
//                             isEmail: true,
//                             hintText: "Kode MRZ",
//                             maxLines: 4,
//                             minLines: 2,
//                             fillColor: Colors.transparent,
//                             emptyText: "Kode MRZ",
//                             textInputType: TextInputType.emailAddress,
//                             textInputAction: TextInputAction.next,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         CustomButton(
//                           onTap: () async {
//                             await context
//                                 .read<PassportScannerNotifier>()
//                                 .scanPassport(context)
//                                 .then((passport) {
//                               countryCodeC.text = passport.countryCode;
//                               passportNumberC.text =
//                                   passport.passportNumber ?? '';
//                               fullNameC.text = passport.fullName ?? '';
//                               nationalityC.text = passport.nationality;
//                               placeOfBirthC.text = passport.placeOfBirth ?? '';
//                               genderC.text = passport.gender ?? '';
//                               dateOfIssueC.text = passport.dateOfIssue ?? '';
//                               dateOfBirthC.text = passport.dateOfBirth ?? '';
//                               dateOfExpiryC.text = passport.dateOfExpiry ?? '';
//                               registrationNumberC.text =
//                                   passport.registrationNumber ?? '';
//                               issuingAuthorityC.text =
//                                   passport.issuingAuthority ?? '';
//                               mrzCodeC.text = passport.mrzCode ?? '';
//                             });
//                           },
//                           isBorder: false,
//                           isBorderRadius: true,
//                           isBoxShadow: false,
//                           btnColor: ColorResources.white,
//                           btnTxt: "Scan Paspor",
//                           loadingColor: primaryColor,
//                           btnTextColor: ColorResources.black,
//                         ),
//                         const SizedBox(height: 8),
//                         CustomButton(
//                           onTap: () {
//                             if (formIsValidate) {
//                               Navigator.pushNamed(
//                                   context, RoutesNavigation.register);
//                             } else {
//                               ShowSnackbar.snackbarErr("Passpor Harap di Lengkapi");
//                             }
//                           },
//                           isBorder: false,
//                           isBorderRadius: true,
//                           isBoxShadow: false,
//                           btnColor: ColorResources.white,
//                           btnTxt: "Register",
//                           loadingColor: primaryColor,
//                           btnTextColor: ColorResources.black,
//                         ),
//                         const SizedBox(height: 20.0),
//                       ],
//                     ))
//               ])),
//         ),
//       ),
//     );
//   }
// }
