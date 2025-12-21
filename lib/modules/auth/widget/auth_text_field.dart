import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:rakhsa/core/formatters/text_field_formatter.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onFieldSubmitted,
    this.validator,
    this.autovalidateMode,
    this.fullname = false,
    this.password = false,
    this.phone = false,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool fullname;
  final bool password;
  final bool phone;
  final AutovalidateMode? autovalidateMode;
  final void Function(String val)? onFieldSubmitted;
  final String? Function(String? val)? validator;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _hidePassword = true;

  void _togglePassword() {
    if (!widget.password) return;
    setState(() => _hidePassword = !_hidePassword);
  }

  TextInputType get _keyboardType {
    if (widget.phone) return TextInputType.phone;
    if (widget.password) return TextInputType.visiblePassword;
    return TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(100);
    final forrmatters = <TextInputFormatter>[
      if (widget.fullname) CapitalizeEachWordFormatter(),
      if (widget.phone) PhoneNumberFormatter(),
    ];

    return Column(
      spacing: 12,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                selectionHandleColor: Colors.white,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              autovalidateMode:
                  widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
              focusNode: widget.focusNode,
              cursorColor: Colors.white,
              cursorErrorColor: Colors.white,
              inputFormatters: forrmatters,
              keyboardType: _keyboardType,
              obscureText: widget.password && _hidePassword,
              onFieldSubmitted: widget.onFieldSubmitted,
              style: TextStyle(color: Colors.white),
              validator: (value) {
                final val = widget.phone
                    ? PhoneNumberFormatter.unmask(value)
                    : value;
                return widget.validator?.call(val);
              },
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 0.5),
                  borderRadius: borderRadius,
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.8),
                  borderRadius: borderRadius,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: borderRadius,
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: borderRadius,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 0.5),
                  borderRadius: borderRadius,
                ),
                errorStyle: TextStyle(color: Colors.white),
                suffixIcon: _renderSuffix(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _renderSuffix() {
    if (!widget.password) return null;
    return IconButton(
      onPressed: _togglePassword,
      icon: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _hidePassword
            ? Icon(
                key: ValueKey("invisible"),
                IconsaxPlusBold.eye_slash,
                color: Colors.white,
              )
            : Icon(
                key: ValueKey("visible"),
                IconsaxPlusBold.eye,
                color: Colors.white,
              ),
      ),
    );
  }
}
