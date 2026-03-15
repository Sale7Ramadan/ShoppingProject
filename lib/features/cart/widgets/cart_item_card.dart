import 'package:flutter/material.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final bool isSelected;
  final ValueChanged<bool?> onSelectionChanged;
  final Future<void> Function() onDelete;

  const CartItemCard({
    super.key,
    required this.itemData,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final quantity = itemData['quantity'] ?? 1;
    final price = double.tryParse(itemData['price'].toString()) ?? 0;
    final totalItemPrice = price * quantity;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    itemData['image'],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemData['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'السعر: ${totalItemPrice.toStringAsFixed(0)} د.ع',
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('الكمية: $quantity'),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: onSelectionChanged,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.straighten, size: 18),
                const SizedBox(width: 6),
                Text(
                  'المقاس: ${itemData['selectedSize'] ?? '-'}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
