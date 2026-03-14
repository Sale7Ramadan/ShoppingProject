import 'package:flutter/material.dart';

class CategoryDropdown extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryDropdown({super.key, required this.onCategorySelected});

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final List<String> categories = ['حقائب', 'كنادر', 'شحاطات'];
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
        widget.onCategorySelected(value!);
      },
      decoration: InputDecoration(
        labelText: 'اختر الفئة',
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      dropdownColor: Colors.grey[800],
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى اختيار الفئة';
        }
        return null;
      },
    );
  }
}
