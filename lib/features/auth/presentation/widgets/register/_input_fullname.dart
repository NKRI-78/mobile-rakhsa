part of '../../pages/register/register.dart';

class _InputFullname extends StatelessWidget {
  const _InputFullname();

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Nama Lengkap',
      isName: true,
      onChanged: (p0) {},
      hintText: "Nama Lengkap",
      fillColor: Colors.transparent,
      emptyText: "Nama Lengkap wajib di isi",
      textInputType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
  }
}