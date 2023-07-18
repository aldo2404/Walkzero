import 'package:flutter/material.dart';
import 'package:walkzero/screens/constants.dart';

// ignore: must_be_immutable
class ReuseTextField extends StatelessWidget {
  TextEditingController controller;
  String? hintText;
  Widget? prefixIcon;
  Widget? suffixIcon;
  bool? obscureText;
  FormFieldValidator? validator;

  ReuseTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText,
    this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: TextFormField(
        validator: validator,
        obscureText: obscureText!,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          helperText: '',
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: subtitleSize),
          contentPadding: const EdgeInsets.fromLTRB(10, 4, 0, 4),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide()),
        ),
      ),
    );
  }
}
