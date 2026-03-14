import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CoustomeTextField extends StatelessWidget {
  CoustomeTextField({
    this.TextHelp,
    this.OnChanged,
    this.obscure = false,
    this.initialValue,
    this.suffixIcon,
  });

  final Function(String)? OnChanged;
  final String? TextHelp;
  final bool obscure;
  final String? initialValue;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      style: TextStyle(color: Colors.white),
      validator: (data) {
        if (data == null || data.isEmpty) {
          return 'Value is Null';
        }
        return null;
      },
      obscureText: obscure,
      onChanged: OnChanged,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.white),
        ),
        hintText: TextHelp,
        hintStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.white),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
