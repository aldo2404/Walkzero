import 'package:flutter/material.dart';
import 'package:walkzero/screens/constants.dart';

// ignore: must_be_immutable
class ReuseTextField extends StatelessWidget {
  TextEditingController controller;
  String? hintText;
  Widget? prefixIcon;
  Widget? suffixIcon;
  String? helperText;
  bool obscureText;
  FormFieldValidator? validator;

  ReuseTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.helperText,
    this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: TextFormField(
        validator: validator,
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          helperText: helperText,
          hintText: hintText,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green.shade300)),
          focusColor: Theme.of(context).focusColor,
          hintStyle: const TextStyle(fontSize: subtitleSize),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide()),
        ),
      ),
    );
  }
}
