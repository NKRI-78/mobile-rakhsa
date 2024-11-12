part of '../../pages/register.dart';

class InputPassport extends StatelessWidget {
  const InputPassport({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Nomor Passport',
      isPhoneNumber: true,
      maxLength: 13,
      onChanged: (p0) {},
      hintText: "Nomor Passport",
      fillColor: Colors.transparent,
      emptyText: "Nomor Passport wajib di isi",
      textInputType: TextInputType.number,
      textInputAction: TextInputAction.next,
    );
  }
}