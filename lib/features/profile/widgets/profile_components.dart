import 'package:flutter/material.dart';
import 'package:shopping_app/core/constants/app_constants.dart';

class ProfileCardContainer extends StatelessWidget {
  final Widget child;

  const ProfileCardContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: child,
      ),
    );
  }
}

class ProfileSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  const ProfileSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.isEditing,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: kPrimaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: onToggleEdit,
          icon: Icon(isEditing ? Icons.cancel : Icons.edit, color: kPrimaryColor),
          label: Text(
            isEditing ? 'إلغاء' : 'تعديل',
            style: const TextStyle(color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}

class ProfilePrimaryActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String text;

  const ProfilePrimaryActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
