import 'package:flutter/material.dart';

var baseDarkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    surface: Color(0xff000000),
    background: Color(0xff000000),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: redColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);

var baseTheme = ThemeData(
  colorScheme: const ColorScheme.light(),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: redColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);

const redColor = Color(0xffFC0102);
const errorColor = Color(0xffFC0102);
const primaryColor = Color(0XFFC82927);
const yellowColor = Color(0xffFACF24);
const whiteColor = Color(0xffFFFFFF);
const greyDescColor = Color(0xff8C8C8C);
const greyColor = Color(0xffE8EDF6);
const successColor = Color(0xFF0DBE49);
const greenColor = Color(0xFF0DBE49);
const orangeColor = Color(0xFFEC7D1E);
const blackColor = Color(0xFF070707);
const greyInputColor = Color(0xFFC7C7C7);
const circleUnselect = Color(0xFFECECEC);
const circleSelect = Color(0xFFBBBBBB);
const testimoniColor = Color(0xFFE3FCFE);
const gradeAbsenColor = Color(0xFF8484EE);
const gradePraktikColor = Color(0xFFF9E746);
const gradeUtsColor = Color(0xFF4BCC96);
const gradeUasColor = Color(0xFF5AA9F6);
const gradeIpkColor = Color(0xFFF89D4A);

//images
const String loginOrnamen = "assets/images/login-ornament.png";
const String signWithGoogle = "assets/images/sign-with-google.png";

//Font Size
const double fontSizeOverExtraSmall = 9.0;
const double fontSizeExtraSmall = 10.0;
const double fontSizeSmall = 12.0;
const double fontSizeDefault = 14.0;
const double fontSizeLarge = 16.0;
const double fontSizeExtraLarge = 18.0;
const double fontSizeOverLarge = 22.0;
const double fontSizeTitle = 32.0;
