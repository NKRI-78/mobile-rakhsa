import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rakhsa/common/constants/theme.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(r"[a-zA-Z0-9_]+@[a-zA-Z]+\.(com|net|org)$").hasMatch(this);
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? emptyText;
  final bool isPrefixIcon;
  final Widget? prefixIcon;
  final bool isSuffixIcon;
  final Widget? suffixIcon;
  final String? labelText;
  final String? initialValue;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final TextInputType? textInputType;
  final int minLines;
  final int maxLines;
  final FocusNode? focusNode;
  final FocusNode? nextNode;
  final TextInputAction? textInputAction;
  final Color counterColor;
  final Color fillColor;
  final Color cursorColor;
  final bool isPhoneNumber;
  final bool isAllowedSymbol;
  final bool isEmail;
  final bool isPassword;
  final bool isName;
  final bool isAlphabetsAndNumbers;
  final bool isBorder;
  final bool isBorderRadius;
  final bool readOnly;
  final bool isEnabled;
  final bool isCapital;
  final int? maxLength;
  final Function()? onEditingComplete;
  final Function(String?)? onSaved;

  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    this.onChanged,
    this.controller,
    this.isPrefixIcon = false,
    this.prefixIcon,
    this.isSuffixIcon = false,
    this.suffixIcon,
    this.hintText,
    this.emptyText,
    this.labelText,
    this.initialValue,
    this.floatingLabelBehavior = FloatingLabelBehavior.never,
    this.textInputType,
    this.counterColor = whiteColor,
    this.fillColor = whiteColor,
    this.focusNode,
    this.cursorColor = whiteColor,
    this.nextNode,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines = 1,
    this.isEmail = false,
    this.isPassword = false,
    this.isName = false,
    this.isAlphabetsAndNumbers = false,
    this.isBorder = true,
    this.isBorderRadius = false,
    this.readOnly = false,
    this.isEnabled = true,
    this.isCapital = false,
    this.maxLength,
    this.isPhoneNumber = false,
    this.isAllowedSymbol = false,
    this.onEditingComplete,
    this.onSaved,
  });

  @override
  State<CustomTextField> createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  void toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(context) {
    return TextFormField(
      initialValue: widget.initialValue,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      minLines: widget.maxLines,
      maxLines: widget.maxLines,
      focusNode: widget.focusNode,
      cursorColor: widget.cursorColor,
      keyboardType: widget.textInputType,
      maxLength: widget.maxLength,
      onSaved: widget.onSaved,
      onEditingComplete: widget.onEditingComplete,
      readOnly: widget.readOnly,
      validator: (value) {
        if (value == null || value.isEmpty) {
          widget.focusNode?.requestFocus();
          return widget.emptyText;
        }
        return null;
      },
      onChanged: widget.onChanged,
      enableInteractiveSelection: true,
      textCapitalization: widget.isCapital ? TextCapitalization.words : TextCapitalization.none,
      enabled: widget.isEnabled,
      textInputAction: widget.textInputAction,
      obscureText: widget.isPassword ? obscureText : false,
      style: const TextStyle(
        color: whiteColor,
        fontSize: fontSizeLarge,
      ),
      onFieldSubmitted: (String v) {
        setState(() {
          widget.textInputAction == TextInputAction.done
          ? FocusScope.of(context).consumeKeyboardToken()
          : FocusScope.of(context).requestFocus(widget.nextNode);
        });
      },
      inputFormatters: widget.isAlphabetsAndNumbers
      ? [
          FilteringTextInputFormatter.singleLineFormatter,
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9 ]')),
        ]
      : widget.isName
      ?  [
          FilteringTextInputFormatter.singleLineFormatter,
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))
        ]
      : widget.isEmail
        ? [
            FilteringTextInputFormatter.singleLineFormatter,
          ]
        : widget.isPhoneNumber 
        ? [
            FilteringTextInputFormatter.digitsOnly
          ]
        : widget.isAllowedSymbol ? 
          [
            FilteringTextInputFormatter.singleLineFormatter,
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))
          ] 
        : [
            FilteringTextInputFormatter.singleLineFormatter,
          ],
      decoration: InputDecoration(
        fillColor: widget.fillColor,
        filled: true,
        isDense: true,
        prefixIcon: widget.isPrefixIcon ? widget.prefixIcon : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: toggle,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: whiteColor,
                  size: 18.0,
                ),
              )
            : widget.isSuffixIcon
                ? widget.suffixIcon
                : null,
        counterText: "",
        errorStyle: const TextStyle(
          fontSize: fontSizeLarge,
          color: greyInputColor
        ),
        counterStyle: TextStyle(color: widget.counterColor, fontSize: fontSizeLarge),
        floatingLabelBehavior: widget.floatingLabelBehavior,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: greyColor,
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w500,
        ),
        labelText: widget.labelText,
        labelStyle: const TextStyle(
          fontSize: fontSizeLarge,
          color: whiteColor
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
          color: greyInputColor,
          width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
          color: greyInputColor,
          width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
          color: whiteColor,
          width: 1.0,),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
          color: whiteColor,
          width: 1.0,),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
          color: whiteColor,
          width: 1.0,),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalize(String value) {
  if (value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}