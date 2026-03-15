// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/features/orders/cubit/order_state.dart';
import 'package:shopping_app/core/helpers/app_functions.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersInitial());

  String? filterStatus;
  StreamSubscription? _ordersSubscription;

  Future<double> _getShippingFee() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('shipping_fee')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final fee = data['fee'];
        if (fee is num) {
          return fee.toDouble();
        }
      }
      return 0.0; // Return 0 if no fee is found
    } catch (e) {
      print('Error fetching shipping fee from Firestore: $e');
      return 0.0;
    }
  }

  void loadOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(OrdersError('يرجى تسجيل الدخول'));
      return;
    }

    emit(OrdersLoading());

    double shippingFee = await _getShippingFee();

    Query ordersQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('timestamp', descending: true);

    if (filterStatus != null) {
      ordersQuery = ordersQuery.where('status', isEqualTo: filterStatus);
    }

    _ordersSubscription?.cancel();

    _ordersSubscription = ordersQuery.snapshots().listen(
      (snapshot) {
        final orders = snapshot.docs.map((doc) {
          final orderData = doc.data() as Map<String, dynamic>;
          final price = double.tryParse(orderData['price'].toString()) ?? 0;
          double totalItemPrice = 0;

          if (orderData['quantitiesPerSize'] != null) {
            final quantitiesMap =
                orderData['quantitiesPerSize'] as Map<String, dynamic>;
            quantitiesMap.forEach((_, qty) {
              totalItemPrice += price * (qty ?? 0);
            });
          } else {
            final quantity = orderData['quantity'] ?? 1;
            totalItemPrice = price * quantity;
          }

          // Include shipping fee in the total
          final totalWithShipping = totalItemPrice + shippingFee;

          return {
            ...orderData,
            'docReference': doc.reference,
            'totalWithShipping': totalWithShipping,
          };
        }).toList();
        emit(OrdersLoaded(orders));
      },
      onError: (error) {
        emit(OrdersError(error.toString()));
      },
    );
  }

  void setFilter(String? status) {
    filterStatus = status;
    loadOrders();
  }

  Future<void> cancelOrder(Map<String, dynamic> orderData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final productId = orderData['id'];
      final imageUrl = orderData['image'];
      final orderId = orderData['docReference']?.id;

      Map<String, int> quantities = {};

      if (orderData.containsKey('sizes_quantities')) {
        final rawMap = Map<String, dynamic>.from(orderData['sizes_quantities']);
        quantities = rawMap.map((key, value) => MapEntry(key, value as int));
      } else if (orderData['selectedSize'] != null) {
        quantities = {
          orderData['selectedSize'].toString(): orderData['quantity'] ?? 1,
        };
      }

      if (quantities.isNotEmpty) {
        await returnQuantityToStock(
          productId: productId,
          quantitiesPerSize: quantities,
          image: imageUrl,
        );
      }

      final docRef = orderData['docReference'] as DocumentReference?;
      if (docRef != null) {
        await docRef.update({'status': 'ملغي'});
      }

      if (orderId != null) {
        await FirebaseFirestore.instance
            .collection('adminOrders')
            .doc(orderId)
            .update({'status': 'ملغي'});
      }

      loadOrders();
    } catch (e) {
      emit(OrdersError('خطأ أثناء إلغاء الطلب: $e'));
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
