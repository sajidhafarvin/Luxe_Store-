import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final TextInputType keyboardType;

  const InputField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
