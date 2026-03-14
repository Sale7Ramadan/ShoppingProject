import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductService {
  static Future<void> addProductToCategory({
    required String categoryId,
    required String name,
    required double price,
    required String imageUrl,
    required String description,
  }) async {
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .collection('products')
        .add({
          'name': name,
          'price': price,
          'image': imageUrl,
          'description': description,
          'created_at': Timestamp.now(),
        });
  }
}
