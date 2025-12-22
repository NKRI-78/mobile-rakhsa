import 'package:flutter/material.dart';

class ListCardInformation extends StatelessWidget {
  const ListCardInformation({
    super.key,
    required this.image,
    required this.title,
    required this.onTap,
  });

  final String image;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(image, width: 45.0, height: 45.0),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 25,
          fontWeight: .w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward, size: 30.0),
      onTap: onTap,
      tileColor: Colors.white,
      contentPadding: .symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
    );
  }
}
