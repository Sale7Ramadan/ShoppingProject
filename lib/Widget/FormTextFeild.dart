import 'package:flutter/material.dart';

class ProductTextField extends StatelessWidget {
  final String label;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final String? initialValue; // أضفنا

  const ProductTextField({
    Key? key,
    required this.label,
    required this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.initialValue, // أضفنا
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: label),
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          initialValue: initialValue, // أضفنا هنا
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
