import 'package:flutter/material.dart';

class CartSummaryPanel extends StatelessWidget {
  final double baseTotal;
  final double fullTotal;
  final int selectedCount;
  final bool isPlacingOrder;
  final Future<void> Function() onDeleteSelected;
  final Future<void> Function() onPlaceOrder;

  const CartSummaryPanel({
    super.key,
    required this.baseTotal,
    required this.fullTotal,
    required this.selectedCount,
    required this.isPlacingOrder,
    required this.onDeleteSelected,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'المجموع بدون أجور الشحن: ${baseTotal.toStringAsFixed(0)} د.ع',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'السعر مضاف إليه أجور الشحن: ${fullTotal.toStringAsFixed(0)} د.ع',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: selectedCount > 0 ? onDeleteSelected : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  label: const Text(
                    'حذف المحدد',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: selectedCount > 0 && !isPlacingOrder ? onPlaceOrder : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: isPlacingOrder
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.shopping_cart_checkout,
                          color: Colors.white,
                        ),
                  label: Text(
                    isPlacingOrder ? 'جارٍ المعالجة...' : 'اطلب الآن',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CartProcessingOverlay extends StatelessWidget {
  const CartProcessingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 12),
              Text(
                'جارٍ المعالجة...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
