// orders_cubit.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/Cubit/AdminOrder/OrderAdminState.dart';
import 'package:shopping_app/helper/Function.dart';

class OrdersAdminCubit extends Cubit<OrdersAdminState> {
  OrdersAdminCubit() : super(OrdersAdminState());

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  void fetchShippingFee() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final doc = await firestore
          .collection('settings')
          .doc('shipping_fee')
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final fee = data['fee'];
        if (fee is num) {
          emit(state.copyWith(shippingFee: fee.toDouble(), isLoading: false));
          return;
        }
      }
      emit(state.copyWith(shippingFee: 0.0, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'خطأ في تحميل أجور الشحن',
        ),
      );
    }
  }

  void listenOrders({String? filterStatus}) {
    _ordersSubscription?.cancel();

    Query query = firestore
        .collection('adminOrders')
        .orderBy('timestamp', descending: true);

    if (filterStatus != null && filterStatus != 'all') {
      query = query.where('status', isEqualTo: filterStatus);
    }

    _ordersSubscription = query.snapshots().listen(
      (snapshot) {
        emit(state.copyWith(orders: snapshot.docs, filterStatus: filterStatus));
      },
      onError: (error) {
        emit(state.copyWith(errorMessage: error.toString()));
      },
    );
  }

  Future<void> updateOrderStatus(
    String userId,
    String orderId,
    String newStatus,
    Map<String, dynamic> orderData,
  ) async {
    try {
      // تحديث حالة الطلب عند المستخدم
      await firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});

      // تحديث حالة الطلب عند الأدمن
      await firestore.collection('adminOrders').doc(orderId).update({
        'status': newStatus,
      });

      // في حال تم الإلغاء، نعيد الكمية إلى المخزون
      if (newStatus == 'ملغي') {
        final productId = orderData['id'];
        Map<String, int> quantities = {};

        // ✅ هنا التعديل المهم:
        if (orderData.containsKey('sizes_quantities')) {
          final rawMap = Map<String, dynamic>.from(
            orderData['sizes_quantities'],
          );
          quantities = rawMap.map(
            (key, value) => MapEntry(key.toString(), value as int),
          );
        } else if (orderData['selectedSize'] != null) {
          final size = orderData['selectedSize'].toString();
          final qty = orderData['quantity'] ?? 1;
          quantities = {size: qty};
        }

        final image = orderData['image'] as String?;

        print('🚩 productId: $productId');
        print('🚩 quantities: $quantities');
        print('🚩 image: $image');

        if (quantities.isNotEmpty && productId != null) {
          await returnQuantityToStock(
            productId: productId,
            quantitiesPerSize: quantities,
            image: image,
          );
        } else {
          print(
            'ℹ️ لم يتم العثور على المقاسات لإعادتها أو لم يتم تعديل أي كمية.',
          );
        }
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء تحديث حالة الطلب: $e');
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
