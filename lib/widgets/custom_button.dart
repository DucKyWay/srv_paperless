import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget text;
  final double? height;
  final double? width;
  final VoidCallback? onPressed;
  final Color color;
  final double? border;

  const CustomButton({
    super.key,
    this.height,
    required this.text,
    this.onPressed,
    this.width,
    this.border,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(border ?? 15),
          ),
        ),
        onPressed: onPressed,
        child: text,
      ),
    );
  }
}

class CancelAndConfirmRowWidget extends StatelessWidget {
  final VoidCallback onConfirm;

  const CancelAndConfirmRowWidget({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            height: 55,
            text: const Text("ยกเลิก", style: TextStyle(color: Colors.white)),
            border: 15,
            color: Theme.of(context).colorScheme.onErrorContainer,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            height: 55,
            text: const Text("ตกลง", style: TextStyle(color: Colors.white)),
            border: 15,
            color: const Color(0xFF1D4200),
            onPressed: onConfirm,
          ),
        ),
      ],
    );
  }
}
