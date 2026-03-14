import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/features/cart/cubit/cart_cubit.dart';
import 'package:shopping_app/features/cart/cubit/cart_state.dart';
import 'package:shopping_app/features/cart/views/address_entry_page.dart';
import 'package:shopping_app/core/helpers/app_functions.dart';

class CartPage extends StatelessWidget {
  static const String id = 'cart_page';

  final VoidCallback? onBack;
  const CartPage({super.key, this.onBack});

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
      return 0.0;
    } catch (e) {
      print('Error fetching shipping fee from Firestore: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text('سلة المشتريات', style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          actions: [
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final cubit = context.read<CartCubit>();
                return Row(
                  children: [
                    Text(
                      '${cubit.selectedCount}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Checkbox(
                      value: cubit.allSelected,
                      onChanged: (val) => cubit.toggleSelectAll(val),
                      checkColor: Colors.white,
                    ),
                  ],
                );
              },
            ),
            SizedBox(width: 12),
          ],
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
          ),
        ),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final cubit = context.read<CartCubit>();

            if (state.loading) {
              return Center(child: CircularProgressIndicator());
            }

            final items = state.items;
            if (items.isEmpty) {
              return Center(
                child: Text('السلة فارغة 🛒', style: TextStyle(fontSize: 18)),
              );
            }

            return FutureBuilder<double>(
              future: _getShippingFee(),
              builder: (context, snapshot) {
                final shippingFee = snapshot.data ?? 0.0;
                final baseTotal = cubit.totalPrice;
                final fullTotal = baseTotal + shippingFee;
                return Stack(
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.only(bottom: 160),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final id = items.keys.elementAt(index);
                        final data = items[id]!;

                        final quantity = data['quantity'] ?? 1;
                        final price =
                            double.tryParse(data['price'].toString()) ?? 0;
                        final totalItemPrice = price * quantity;

                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        data['image'],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'السعر: ${totalItemPrice.toStringAsFixed(0)} د.ع',
                                            style: TextStyle(
                                              color: Colors.deepPurple,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text('الكمية: $quantity'),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Checkbox(
                                          value: state.selected[id] ?? false,
                                          onChanged: (val) =>
                                              cubit.toggleSelection(id, val),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            await cubit.deleteItem(id);
                                            if (context.mounted) {
                                              WarrningMessage(
                                                context,
                                                'تم حذف المنتج من السلة',
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(height: 20),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.straighten, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'المقاس: ${data['selectedSize'] ?? '-'}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, -2),
                            ),
                          ],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'المجموع بدون أجور الشحن: ${baseTotal.toStringAsFixed(0)} د.ع',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'السعر مضاف إليه أجور الشحن: ${fullTotal.toStringAsFixed(0)} د.ع',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: cubit.selectedCount > 0
                                        ? () async {
                                            await cubit.deleteSelectedItems();
                                            if (context.mounted) {
                                              WarrningMessage(
                                                context,
                                                'تم حذف المنتجات المحددة',
                                              );
                                            }
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.delete_forever,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'حذف المحدد',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        cubit.selectedCount > 0 &&
                                            !state.isPlacingOrder
                                        ? () async {
                                            cubit.setPlacingOrder(true);

                                            await cubit.placeOrder(
                                              (msg) {
                                                if (context.mounted) {
                                                  WarrningMessage(context, msg);
                                                }
                                              },
                                              () {
                                                if (context.mounted) {
                                                  Navigator.pushNamed(
                                                    context,
                                                    AddressEntryPage.id,
                                                  );
                                                }
                                              },
                                            );

                                            if (context.mounted) {
                                              WarrningMessage(
                                                context,
                                                'تم إرسال الطلب بنجاح ✅',
                                              );
                                            }

                                            cubit.setPlacingOrder(false);
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    icon: state.isPlacingOrder
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            Icons.shopping_cart_checkout,
                                            color: Colors.white,
                                          ),
                                    label: Text(
                                      state.isPlacingOrder
                                          ? 'جارٍ المعالجة...'
                                          : 'اطلب الآن',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Overlay loading to block interaction and show spinner
                    if (state.isPlacingOrder)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 12),
                                Text(
                                  'جارٍ المعالجة...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
