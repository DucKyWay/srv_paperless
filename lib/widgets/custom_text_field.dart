import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller, 
    this.isPassword = false,
    this.keyboardType = TextInputType.text, 
    this.inputFormatters,
    this.onTap,
    this.readOnly = false,
    this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,style: TextStyle(fontSize: 14),),
        TextFormField(
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }
}