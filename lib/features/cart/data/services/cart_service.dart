import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  static Future<void> addToCart({
    required String productId,
    required Map<String, dynamic> productData,
    required List<int> selectedSizes,
    required int quantity,
    required Map<int, int> quantitiesPerSize,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(productId);
    final productSnap = await productRef.get();
    final product = productSnap.data();

    if (product == null) return;

    final selectedImage = productData['image'];
    final subImages = List<Map<String, dynamic>>.from(product['sub_images']);
    final subIndex = subImages.indexWhere(
      (img) => img['image'] == selectedImage,
    );
    if (subIndex == -1) return;

    final subImage = subImages[subIndex];
    final available = Map<String, dynamic>.from(
      subImage['sizes_quantities'] ?? {},
    );

    if (selectedSizes.isEmpty) {
      // بدون مقاسات
      final sizeKey = '0';
      final qty = quantity;
      final availableQty = available[sizeKey] ?? 0;

      if (qty > availableQty) {
        throw Exception('الكمية المطلوبة غير متوفرة');
      }

      final price = productData['price'] ?? 0;
      final totalPrice = price * qty;

      await cartRef.add({
        ...productData,
        'quantity': qty,
        'selectedSize': 0,
        'totalPrice': totalPrice,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // خصم الكمية
      available[sizeKey] = (availableQty - qty)
          .clamp(0, double.infinity)
          .toInt();
    } else {
      // مع مقاسات - كل مقاس ينضاف كعنصر مستقل
      for (final size in selectedSizes) {
        final qty = quantitiesPerSize[size] ?? 0;
        final sizeKey = size.toString();
        final availableQty = available[sizeKey] ?? 0;

        if (qty > availableQty) {
          throw Exception('الكمية المطلوبة غير متوفرة للمقاس $size');
        }
      }

      for (final size in selectedSizes) {
        final qty = quantitiesPerSize[size] ?? 0;
        if (qty <= 0) continue;

        final price = productData['price'] ?? 0;
        final totalPrice = price * qty;

        await cartRef.add({
          ...productData,
          'selectedSize': size,
          'quantity': qty,
          'totalPrice': totalPrice,
          'timestamp': FieldValue.serverTimestamp(),
          'sizes_quantities': {size.toString(): qty},
        });

        final sizeKey = size.toString();
        available[sizeKey] = (available[sizeKey] - qty)
            .clamp(0, double.infinity)
            .toInt();
      }
    }

    subImages[subIndex]['sizes_quantities'] = available;
    await productRef.update({'sub_images': subImages});
  }

  static Future<void> releaseQuantity({
    required String productId,
    required String image,
    required int size,
    required int quantity,
  }) async {
    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(productId);
    final productSnap = await productRef.get();

    if (!productSnap.exists) return;
    final product = productSnap.data();
    if (product == null) return;

    final subImages = List<Map<String, dynamic>>.from(product['sub_images']);
    final subIndex = subImages.indexWhere((img) => img['image'] == image);
    if (subIndex == -1) return;

    final subImage = subImages[subIndex];
    final available = Map<String, dynamic>.from(
      subImage['sizes_quantities'] ?? {},
    );

    final sizeKey = size.toString();
    final currentAvailable = available[sizeKey] ?? 0;

    available[sizeKey] = (currentAvailable + quantity);

    subImages[subIndex]['sizes_quantities'] = available;
    await productRef.update({'sub_images': subImages});
  }
}
