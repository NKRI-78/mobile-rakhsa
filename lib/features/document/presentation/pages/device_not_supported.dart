import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';

class DeviceNotSupported extends StatelessWidget {
  const DeviceNotSupported({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.warning),
        const SizedBox(height: 16),
        Text(
          'Device Tidak Mendukung', 
          style: Theme.of(context).textTheme.titleLarge, 
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Maaf perangkat ini tidak didukung fitur scan document karena tidak memenuhi spesifikasi google play service', 
          style: Theme.of(context).textTheme.bodySmall, 
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Material(
          borderRadius: BorderRadius.circular(16),
          color: redColor,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(100),
            child: const Padding(
              padding: EdgeInsets.all(100),
              child: Text(
                'Kembali', 
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}