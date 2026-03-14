import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/Screens/Product_Page.dart';

void goToCategory(BuildContext context, String title, bool isAdmin) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProductPage(isAdmin: isAdmin),
      settings: RouteSettings(arguments: title),
    ),
  );
}

void WarrningMessage(BuildContext context, String message) {
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

List<int> getSizesByCategory(String category) {
  if (category.contains('رجالي'))
    return List.generate(6, (i) => 40 + i); // 40-45
  if (category.contains('نسائي'))
    return List.generate(6, (i) => 36 + i); // 36-41
  if (category.contains('محير'))
    return List.generate(6, (i) => 31 + i); // 31-36
  if (category.contains('بيبي'))
    return List.generate(5, (i) => 21 + i); // 21-25
  if (category.contains('أطفال'))
    return List.generate(5, (i) => 26 + i); // 26-30
  return [];
}

Future<List<Map<String, dynamic>>> fetchOrdersByStatus(String status) async {
  List<Map<String, dynamic>> allOrders = [];

  final usersSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .get();

  for (var userDoc in usersSnapshot.docs) {
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDoc.id)
        .collection('orders')
        .where('status', isEqualTo: status)
        .get();

    for (var orderDoc in ordersSnapshot.docs) {
      final orderData = orderDoc.data();
      orderData['userId'] = userDoc.id;
      orderData['orderId'] = orderDoc.id;
      allOrders.add(orderData);
    }
  }

  return allOrders;
}

Future<bool> isConnectedToInternet() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

Future<void> returnQuantityToStock({
  required String productId,
  required Map<String, int> quantitiesPerSize,
  String? image,
}) async {
  final productRef = FirebaseFirestore.instance
      .collection('products')
      .doc(productId);
  final productSnap = await productRef.get();

  if (!productSnap.exists) return;

  final productData = productSnap.data();
  if (productData == null) return;

  final List<dynamic> subImages = productData['sub_images'] ?? [];
  bool hasChange = false;

  for (int i = 0; i < subImages.length; i++) {
    final subImage = Map<String, dynamic>.from(subImages[i]);
    if (subImage['image'] == image) {
      final sizesMap = Map<String, dynamic>.from(
        subImage['sizes_quantities'] ?? {},
      );

      print('قبل التعديل - subImage[$i] sizes_quantities: $sizesMap');

      quantitiesPerSize.forEach((size, qty) {
        final key = size.toString();
        if (sizesMap.containsKey(key)) {
          final currentQty = (sizesMap[key] ?? 0) as int;
          sizesMap[key] = currentQty + qty;
          print('✅ تم تعديل sub_image[$i] المقاس $key: +$qty');
          hasChange = true;
        } else {
          print('⚠️ المقاس $key غير موجود في الصورة الفرعية $i');
        }
      });

      print('بعد التعديل - subImage[$i] sizes_quantities: $sizesMap');

      subImages[i]['sizes_quantities'] = sizesMap;
      break;
    }
  }

  if (hasChange) {
    try {
      await productRef.update({'sub_images': subImages});
      print('✅ تمت إعادة الكمية إلى sub_images بنجاح.');
    } catch (e) {
      print('❌ خطأ في تحديث sub_images: $e');
    }
  } else {
    print('ℹ️ لم يتم العثور على المقاسات لإعادتها أو لم يتم تعديل أي كمية.');
  }
}

Map<String, int> getQuantitiesFromSubImages(List<dynamic> subImages) {
  Map<String, int> quantities = {};

  for (var subImage in subImages) {
    if (subImage is Map<String, dynamic> &&
        subImage.containsKey('sizes_quantities')) {
      final sizesMap = Map<String, dynamic>.from(subImage['sizes_quantities']);
      sizesMap.forEach((size, qty) {
        final key = size.toString();
        final currentQty = quantities[key] ?? 0;
        quantities[key] = currentQty + (qty as int);
      });
    }
  }

  return quantities;
}
