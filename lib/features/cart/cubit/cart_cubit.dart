import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/features/cart/cubit/cart_state.dart';
import 'package:shopping_app/features/cart/data/services/cart_service.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState(items: {}, selected: {}, loading: false)) {
    _init();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _init() async {
    await loadCart();
    _listenToCartChanges();
  }

  void setPlacingOrder(bool val) {
    emit(state.copyWith(isPlacingOrder: val));
  }

  void _listenToCartChanges() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          final newItems = <String, Map<String, dynamic>>{};
          final newSelected = Map<String, bool>.from(state.selected);

          for (var doc in snapshot.docs) {
            newItems[doc.id] = doc.data();

            // لو العنصر جديد، عيّن اختيار افتراضي false
            if (!newSelected.containsKey(doc.id)) {
              newSelected[doc.id] = false;
            }
          }

          // حذف العناصر المختارة اللي ما عاد موجودة
          final toRemove = newSelected.keys
              .where((key) => !newItems.containsKey(key))
              .toList();
          for (var key in toRemove) {
            newSelected.remove(key);
          }

          emit(
            state.copyWith(
              items: newItems,
              selected: newSelected,
              loading: false,
            ),
          );
        });
  }

  Future<void> loadCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    emit(state.copyWith(loading: true));

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .orderBy('timestamp', descending: true)
        .get();

    final newItems = <String, Map<String, dynamic>>{};
    final newSelected = <String, bool>{};

    for (var doc in snapshot.docs) {
      newItems[doc.id] = doc.data();
      newSelected[doc.id] = false;
    }

    emit(
      state.copyWith(items: newItems, selected: newSelected, loading: false),
    );
  }

  void toggleSelection(String id, bool? value) {
    final updated = Map<String, bool>.from(state.selected);
    updated[id] = value ?? false;
    emit(state.copyWith(selected: updated));
  }

  void toggleSelectAll(bool? value) {
    final selectAll = value ?? false;
    final updated = <String, bool>{};
    for (var key in state.items.keys) {
      updated[key] = selectAll;
    }
    emit(state.copyWith(selected: updated));
  }

  // دالة لحساب مجموع الكميات من sizes_quantities
  int calculateTotalQuantity(Map<String, dynamic>? sizesQuantities) {
    if (sizesQuantities == null) return 1;
    int total = 0;
    sizesQuantities.forEach((key, value) {
      total += (value as int);
    });
    return total > 0 ? total : 1;
  }

  double get totalPrice {
    double total = 0;
    state.selected.forEach((key, isSelected) {
      if (isSelected) {
        final item = state.items[key];
        if (item != null) {
          final price = double.tryParse(item['price'].toString()) ?? 0;
          final quantity = item['quantity'] ?? 1;
          total += price * quantity;
        }
      }
    });
    return total;
  }

  int get selectedCount =>
      state.selected.values.where((element) => element).length;

  bool get allSelected =>
      state.selected.isNotEmpty &&
      state.selected.values.every((element) => element);

  Future<void> deleteItem(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final item = state.items[id];
    if (item != null) {
      final quantity = item['quantity'] ?? 0;
      final size = item['selectedSize'] ?? 0;

      await CartService.releaseQuantity(
        productId: item['id'],
        image: item['image'],
        size: size,
        quantity: quantity,
      );
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(id)
        .delete();
  }

  Future<void> deleteSelectedItems() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final selectedIds = state.selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    for (var id in selectedIds) {
      final item = state.items[id];
      if (item != null) {
        final quantity = item['quantity'] ?? 0;
        final size = item['selectedSize'] ?? 0;

        await CartService.releaseQuantity(
          productId: item['id'],
          image: item['image'],
          size: size,
          quantity: quantity,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(id)
            .delete();
      }
    }
  }

  Future<double> _fetchShippingFee() async {
    try {
      final doc = await _firestore
          .collection('settings')
          .doc('shipping_fee')
          .get();
      if (doc.exists && doc.data() != null) {
        final fee = doc.data()!['fee'];
        if (fee is num) return fee.toDouble();
      }
    } catch (e) {
      print('Error fetching shipping fee: $e');
    }
    return 0.0;
  }

  Future<void> placeOrder(
    Function(String) onShowMessage,
    Function onNavigateToAddress,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      onShowMessage('يجب تسجيل الدخول');
      return;
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};
    final address = userData['address'];

    if (address == null ||
        address['street'] == null ||
        address['neighborhood'] == null ||
        address['city'] == null) {
      onNavigateToAddress();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final shippingFee = await _fetchShippingFee();

    final selectedIds = state.selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    for (var id in selectedIds) {
      final itemData = state.items[id];
      if (itemData != null) {
        final newOrderId = _firestore.collection('orders').doc().id;

        final sizesQuantities =
            itemData['sizes_quantities'] as Map<String, dynamic>?;
        final quantity = calculateTotalQuantity(sizesQuantities);

        final price = double.tryParse(itemData['price'].toString()) ?? 0;
        final baseTotal = price * quantity;
        final fullTotal = baseTotal + shippingFee;

        final orderData = {
          ...itemData,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'قيد المعالجة',
          'userId': user.uid,
          'userEmail': user.email,
          'orderId': newOrderId,
          'address': address,
          'shippingFee': shippingFee,
          'totalPrice': baseTotal,
          'totalWithShipping': fullTotal,
        };

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .doc(newOrderId)
            .set(orderData);

        await _firestore
            .collection('adminOrders')
            .doc(newOrderId)
            .set(orderData);

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(id)
            .delete();
      }
    }
  }
}
