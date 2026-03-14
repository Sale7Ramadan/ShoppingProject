import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/Cubit/AdminOrder/OrderAdminCubit.dart';

class OrderItemWidget extends StatelessWidget {
  final Map<String, dynamic> order;
  final String orderId;
  final String status;
  final num price;
  final int quantity;
  final num totalPrice;
  final double shippingFee;

  const OrderItemWidget({
    required this.order,
    required this.orderId,
    required this.status,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.shippingFee,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrdersAdminCubit>();
    final address = order['address'] as Map<String, dynamic>?;

    final city = address?['city'] ?? '';
    final neighborhood = address?['neighborhood'] ?? '';
    final street = address?['street'] ?? '';
    final userId = order['userId'] ?? '';

    Future<String> fetchPhone() async {
      if (userId.isEmpty) return 'غير متوفر';
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        return data?['phone'] ?? 'غير متوفر';
      }
      return 'غير متوفر';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            order['image'] ?? '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.image_not_supported, size: 50),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order['name'] ?? 'منتج بدون اسم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.deepPurple,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6),

              if (order['sizes_quantities'] != null &&
                  order['sizes_quantities'] is Map)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (order['sizes_quantities'] as Map).entries
                      .map<Widget>((entry) {
                        final size = entry.key.toString();
                        final qty = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            'المقاس $size: الكمية $qty',
                            style: TextStyle(fontSize: 13),
                          ),
                        );
                      })
                      .toList(),
                )
              else
                Text('الكمية: $quantity', style: TextStyle(fontSize: 13)),

              SizedBox(height: 4),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('تفاصيل العنوان ورقم الموبايل'),
                      content: FutureBuilder<String>(
                        future: fetchPhone(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: 60,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final phone = snapshot.data ?? 'غير متوفر';
                          return Text(
                            'العنوان:\n$street\n$neighborhood\n$city\n\nرقم الموبايل:\n$phone',
                            style: TextStyle(fontSize: 14),
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('إغلاق'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'عرض العنوان',
                  style: TextStyle(fontSize: 13, color: Colors.blue),
                ),
              ),

              SizedBox(height: 4),
              Text('سعر القطعة: $price د.ع', style: TextStyle(fontSize: 13)),
              SizedBox(height: 4),
              Text(
                'السعر الكلي: ${totalPrice.toInt()} د.ع',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'أجور الشحن: ${shippingFee.toStringAsFixed(0)} د.ع',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: status == 'قيد المعالجة'
                      ? Colors.orange.shade100
                      : status == 'مكتمل'
                      ? Colors.green.shade100
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'قيد المعالجة'
                        ? Colors.orange
                        : status == 'مكتمل'
                        ? Colors.green
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),

              // باقي الأزرار مثل اللي عندك
              if (status == 'قيد المعالجة') ...[
                SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('تأكيد توصيل الطلب'),
                            content: Text(
                              'هل أنت متأكد من أن الطلب تم توصيله؟',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  cubit
                                      .updateOrderStatus(
                                        order['userId'],
                                        orderId,
                                        'مكتمل',
                                        order,
                                      )
                                      .catchError((e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      });
                                },
                                child: Text(
                                  'تأكيد',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(100, 36),
                        textStyle: TextStyle(fontSize: 13),
                      ),
                      child: Text(
                        'تم التوصيل',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('تأكيد إلغاء الطلب'),
                            content: Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  cubit
                                      .updateOrderStatus(
                                        order['userId'],
                                        orderId,
                                        'ملغي',
                                        order,
                                      )
                                      .catchError((e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      });
                                },
                                child: Text(
                                  'تأكيد',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: Size(100, 36),
                        textStyle: TextStyle(fontSize: 13),
                      ),
                      child: Text(
                        'إلغاء الطلب',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
