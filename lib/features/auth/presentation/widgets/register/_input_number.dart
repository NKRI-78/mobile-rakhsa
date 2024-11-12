part of '../../pages/register.dart';

class InputNumber extends StatelessWidget {
  const InputNumber({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Nomor Handphone',
      isPhoneNumber: true,
      maxLength: 13,
      onChanged: (p0) {},
      hintText: "Nomer Handphone",
      fillColor: Colors.transparent,
      emptyText: "Nomer Handphone wajib di isi",
      textInputType: TextInputType.number,
      textInputAction: TextInputAction.next,
    );
  }
}