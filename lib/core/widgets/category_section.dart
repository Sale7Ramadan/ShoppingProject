import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final Function(String)? onTap;

  const CategorySection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      children: items
          .map(
            (item) =>
                ListTile(title: Text(item), onTap: () => onTap?.call(item)),
          )
          .toList(),
    );
  }
}
