part of '../../pages/register.dart';

class _FieldPassword extends StatelessWidget {
  const _FieldPassword();

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      onChanged: (value) {},
      labelText: "Kata Sandi",
      isPassword: true,
      hintText: "Kata Sandi",
      fillColor: Colors.transparent,
      emptyText: "Kata Sandi tidak boleh kosong",
      textInputType: TextInputType.text,
      textInputAction: TextInputAction.done,
    );
  }
}
