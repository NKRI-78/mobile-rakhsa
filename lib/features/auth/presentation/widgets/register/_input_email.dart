part of '../../pages/register.dart';

class InputEmail extends StatelessWidget {
  const InputEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Alamat Email',
      isEmail: true,
      onChanged: (p0) {},
      hintText: "Alamat Email",
      fillColor: Colors.transparent,
      emptyText: "Email wajib di isi",
      textInputType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
  }
}