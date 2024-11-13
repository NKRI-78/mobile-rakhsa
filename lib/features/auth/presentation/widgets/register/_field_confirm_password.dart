part of '../../pages/register/register.dart';

class _FieldConfirmPassword extends StatelessWidget {
  const _FieldConfirmPassword();

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      onChanged: (value) {},
      labelText: "Konfirmasi Kata Sandi",
      isPassword: true,
      hintText: "Konfirmasi Kata Sandi",
      fillColor: Colors.transparent,
      emptyText: "Konfirmasi Kata Sandi tidak boleh kosong",
      textInputType: TextInputType.text,
      textInputAction: TextInputAction.done,
    );
  }
}
