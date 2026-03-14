import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/features/orders/cubit/order_cubit.dart';
import 'package:shopping_app/features/orders/cubit/order_state.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/core/helpers/app_functions.dart';

class OrdersPage extends StatelessWidget {
  final VoidCallback? onBack;
  const OrdersPage({super.key, this.onBack});
  static const String id = 'OrderPage';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit()..loadOrders(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلباتي', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
          ),
          actions: [_FilterMenu()],
        ),
        body: const _OrdersList(),
      ),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list, color: Colors.white),
      onSelected: (value) {
        context.read<OrdersCubit>().setFilter(
          value == 'كل الطلبات' ? null : value,
        );
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'كل الطلبات', child: Text('كل الطلبات')),
        PopupMenuItem(
          value: 'قيد المعالجة',
          child: Text('الطلبات قيد المعالجة'),
        ),
        PopupMenuItem(value: 'مكتمل', child: Text('الطلبات المكتملة')),
        PopupMenuItem(value: 'ملغي', child: Text('الطلبات الملغية')),
      ],
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OrdersError) {
          return Center(child: Text(state.message));
        } else if (state is OrdersLoaded) {
          final docs = state.orders;
          if (docs.isEmpty) {
            return const Center(child: Text('لا يوجد طلبات حالياً'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];

              final price = double.tryParse(data['price'].toString()) ?? 0;
              final shippingFee =
                  double.tryParse(data['shippingFee']?.toString() ?? '0') ?? 0;

              num totalItemPrice = 0;
              if (data['sizes_quantities'] != null &&
                  data['sizes_quantities'] is Map) {
                final quantitiesMap =
                    data['sizes_quantities'] as Map<String, dynamic>;
                quantitiesMap.forEach((_, qty) {
                  totalItemPrice += (price * (qty ?? 0));
                });
              } else {
                final quantity = data['quantity'] ?? 1;
                totalItemPrice = price * quantity;
              }

              final totalWithShipping = totalItemPrice + shippingFee;

              final status = data['status'] ?? 'قيد المعالجة';

              Color statusColor;
              switch (status) {
                case 'قيد المعالجة':
                  statusColor = Colors.orange;
                  break;
                case 'مكتمل':
                  statusColor = Colors.green;
                  break;
                case 'ملغي':
                  statusColor = Colors.grey;
                  break;
                default:
                  statusColor = Colors.blueGrey;
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              data['image'] ?? '',
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                size: 90,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'منتج بدون اسم',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (data['sizes_quantities'] != null &&
                                    data['sizes_quantities'] is Map)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: (data['sizes_quantities'] as Map)
                                        .entries
                                        .map<Widget>((entry) {
                                          final size = entry.key.toString();
                                          final qty = entry.value;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 2.0,
                                            ),
                                            child: Text(
                                              'المقاس $size: الكمية $qty',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                  )
                                else
                                  Text('الكمية: ${data['quantity'] ?? 1}'),

                                const SizedBox(height: 4),
                                Text(
                                  'سعر المنتجات: ${totalItemPrice.toStringAsFixed(0)} د.ع',
                                  style: const TextStyle(fontSize: 14),
                                ),

                                const SizedBox(height: 6),
                                Text(
                                  'السعر الكلي مع الشحن: ${totalWithShipping.toStringAsFixed(0)} د.ع',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (status == 'قيد المعالجة')
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('تأكيد إلغاء الطلب'),
                                    content: Text(
                                      'هل أنت متأكد أنك تريد إلغاء هذا الطلب؟',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: Text('لا'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(ctx).pop();
                                          await context
                                              .read<OrdersCubit>()
                                              .cancelOrder(data);
                                          WarrningMessage(
                                            context,
                                            'تم إلغاء الطلب وإعادة الكمية بنجاح',
                                          );
                                        },
                                        child: Text(
                                          'إلغاء',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              label: const Text(
                                'إلغاء الطلب',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}
