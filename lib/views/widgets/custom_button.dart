import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Text text;
  final double height;
  final VoidCallback onPressed;
  final Color color;
  final double border;

  const CustomButton({
    super.key,
    required this.height,
    required this.text,
    required this.onPressed,
    required this.border,
    required this.color,

  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(border),
          ),
        ),
        onPressed: onPressed,
        child:text,
      ),
    );
  }
}