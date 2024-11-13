part of '../../pages/register/register.dart';

class InputNumberUrgent extends StatelessWidget {
  const InputNumberUrgent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Nomor Darurat',
      isPhoneNumber: true,
      maxLength: 13,
      onChanged: (p0) {},
      hintText: "Nomer Darurat",
      fillColor: Colors.transparent,
      emptyText: "Nomer Darurat wajib di isi",
      textInputType: TextInputType.number,
      textInputAction: TextInputAction.next,
    );
  }
}