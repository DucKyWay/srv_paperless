import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget text;
  final double? height;
  final double? width;
  final VoidCallback? onPressed;
  final Color color;
  final double border;

  const CustomButton({
    super.key,
    this.height,
    required this.text,
    this.onPressed,
    this.width,
    required this.border,
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
            borderRadius: BorderRadius.circular(border),
          ),
        ),
        onPressed: onPressed,
        child: text,
      ),
    );
  }
}
