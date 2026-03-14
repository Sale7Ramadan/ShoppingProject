// orders_state.dart
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersAdminState extends Equatable {
  final List<QueryDocumentSnapshot> orders;
  final bool isLoading;
  final String? errorMessage;
  final double shippingFee;
  final String? filterStatus;

  const OrdersAdminState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.shippingFee = 0.0,
    this.filterStatus,
  });

  OrdersAdminState copyWith({
    List<QueryDocumentSnapshot>? orders,
    bool? isLoading,
    String? errorMessage,
    double? shippingFee,
    String? filterStatus,
  }) {
    return OrdersAdminState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      shippingFee: shippingFee ?? this.shippingFee,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  @override
  List<Object?> get props => [
    orders,
    isLoading,
    errorMessage,
    shippingFee,
    filterStatus,
  ];
}
