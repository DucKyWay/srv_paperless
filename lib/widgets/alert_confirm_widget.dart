import 'package:flutter/material.dart';
import 'package:srv_paperless/widgets/custom_button.dart';

class AlertConfirmWidget extends StatelessWidget {
  final String title;
  final VoidCallback onConfirm;

  const AlertConfirmWidget({
    super.key,
    required this.title,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text("ยืนยันการทำรายการ", style: TextStyle(fontWeight: FontWeight.bold))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ]),
      actions: [
        CustomButton(
          height: 55,
          text: Text("ยืนยัน", style: TextStyle(color: Colors.white),),
          border: 15,
          // color: Theme.of(context).colorScheme.tertiaryContainer,
          color: Color(0xFF1D4200),
            onPressed: onConfirm
        ),
        SizedBox(height: 8),
        CustomButton(
          height: 55,
          text: Text("ยกเลิก", style: TextStyle(color: Colors.white),),
          border: 15,
          color: Theme.of(context).colorScheme.onErrorContainer,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
