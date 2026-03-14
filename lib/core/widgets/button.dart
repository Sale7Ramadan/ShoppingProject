import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CoustomeButton extends StatelessWidget {
  CoustomeButton({required this.text, required this.ontap});

  String text;
  VoidCallback? ontap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        height: 50,
        width: double.infinity,
        child: Center(child: Text(text, style: TextStyle(fontSize: 25))),
      ),
    );
  }
}
