import 'package:flutter/material.dart';

abstract class MenuHeaderWidget extends StatelessWidget {
  const MenuHeaderWidget({super.key});

  Widget? buildLeading(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [if (buildLeading(context) != null) buildLeading(context)!],
    );
  }
}

class HeaderNormal extends MenuHeaderWidget {
  const HeaderNormal({super.key});
  @override
  Widget? buildLeading(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "ระบบโครงการออนไลน์",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        "โรงเรียนสารวิทยา",
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    ],
  );
}

class HeaderWithBackButton extends MenuHeaderWidget {
  const HeaderWithBackButton({super.key});
  @override
  Widget? buildLeading(BuildContext context) => Row(
    children: [
      TextButton.icon(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
        label: Text(
          "ย้อนกลับ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white,
          ),
        ),
      ),
    ],
  );
}
