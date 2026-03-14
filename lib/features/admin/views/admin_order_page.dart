import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/features/admin/cubit/order_admin_cubit.dart';
import 'package:shopping_app/features/admin/cubit/order_admin_state.dart';
import 'package:shopping_app/features/orders/widgets/order_item_widget.dart';

class AdminOrdersPage extends StatelessWidget {
  static const String id = 'AdminOrdersPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 33, 23, 23)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
        title: Text('إدارة الطلبات', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              final cubit = context.read<OrdersAdminCubit>();
              final currentFilter = cubit.state.filterStatus ?? 'all';

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('اختر حالة الطلبات'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          title: Text('كل الطلبات'),
                          value: 'all',
                          groupValue: currentFilter,
                          onChanged: (val) {
                            cubit.listenOrders(filterStatus: val);
                            Navigator.pop(context);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('قيد المعالجة'),
                          value: 'قيد المعالجة',
                          groupValue: currentFilter,
                          onChanged: (val) {
                            cubit.listenOrders(filterStatus: val);
                            Navigator.pop(context);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('مكتمل'),
                          value: 'مكتمل',
                          groupValue: currentFilter,
                          onChanged: (val) {
                            cubit.listenOrders(filterStatus: val);
                            Navigator.pop(context);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('ملغي'),
                          value: 'ملغي',
                          groupValue: currentFilter,
                          onChanged: (val) {
                            cubit.listenOrders(filterStatus: val);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            tooltip: 'فلتر الطلبات',
          ),
        ],
      ),
      body: BlocConsumer<OrdersAdminCubit, OrdersAdminState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.orders.isEmpty) {
            return Center(child: Text('لا توجد طلبات حالياً'));
          }

          final shippingFee = state.shippingFee;

          return ListView.separated(
            padding: EdgeInsets.all(12),
            itemCount: state.orders.length,
            separatorBuilder: (_, __) => Divider(height: 12, thickness: 1),
            itemBuilder: (context, index) {
              final orderDoc = state.orders[index];
              final order = orderDoc.data() as Map<String, dynamic>;
              final orderId = orderDoc.id;
              final status = order['status'] ?? 'قيد المعالجة';
              final num price = order['price'] ?? 0;
              final int quantity = order['quantity'] ?? 1;
              final num totalPrice = (price * quantity) + shippingFee;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OrderItemWidget(
                    order: order,
                    orderId: orderId,
                    status: status,
                    price: price,
                    quantity: quantity,
                    totalPrice: totalPrice,
                    shippingFee: shippingFee,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
