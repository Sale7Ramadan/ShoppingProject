import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/core/helpers/app_functions.dart';
import 'package:shopping_app/features/cart/cubit/cart_cubit.dart';
import 'package:shopping_app/features/cart/cubit/cart_state.dart';
import 'package:shopping_app/features/cart/views/address_entry_page.dart';
import 'package:shopping_app/features/cart/widgets/cart_item_card.dart';
import 'package:shopping_app/features/cart/widgets/cart_summary_panel.dart';

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
        final fee = doc.data()!['fee'];
        if (fee is num) {
          return fee.toDouble();
        }
      }
    } catch (e) {
      print('Error fetching shipping fee from Firestore: $e');
    }

    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit(),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final cartCubit = context.read<CartCubit>();

            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.items.isEmpty) {
              return const Center(
                child: Text('السلة فارغة 🛒', style: TextStyle(fontSize: 18)),
              );
            }

            return FutureBuilder<double>(
              future: _getShippingFee(),
              builder: (context, snapshot) {
                final shippingFee = snapshot.data ?? 0.0;
                final baseTotal = cartCubit.totalPrice;
                final fullTotal = baseTotal + shippingFee;

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.only(bottom: 160),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final itemId = state.items.keys.elementAt(index);
                        final itemData = state.items[itemId]!;

                        return CartItemCard(
                          itemData: itemData,
                          isSelected: state.selected[itemId] ?? false,
                          onSelectionChanged: (value) {
                            cartCubit.toggleSelection(itemId, value);
                          },
                          onDelete: () async {
                            await cartCubit.deleteItem(itemId);
                            if (context.mounted) {
                              WarrningMessage(context, 'تم حذف المنتج من السلة');
                            }
                          },
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CartSummaryPanel(
                        baseTotal: baseTotal,
                        fullTotal: fullTotal,
                        selectedCount: cartCubit.selectedCount,
                        isPlacingOrder: state.isPlacingOrder,
                        onDeleteSelected: () async {
                          await cartCubit.deleteSelectedItems();
                          if (context.mounted) {
                            WarrningMessage(context, 'تم حذف المنتجات المحددة');
                          }
                        },
                        onPlaceOrder: () async {
                          cartCubit.setPlacingOrder(true);

                          await cartCubit.placeOrder(
                            (message) {
                              if (context.mounted) {
                                WarrningMessage(context, message);
                              }
                            },
                            () {
                              if (context.mounted) {
                                Navigator.pushNamed(context, AddressEntryPage.id);
                              }
                            },
                          );

                          if (context.mounted) {
                            WarrningMessage(context, 'تم إرسال الطلب بنجاح ✅');
                          }

                          cartCubit.setPlacingOrder(false);
                        },
                      ),
                    ),
                    if (state.isPlacingOrder) const CartProcessingOverlay(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
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
      title: const Text('سلة المشتريات', style: TextStyle(color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      actions: [
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final cartCubit = context.read<CartCubit>();
            return Row(
              children: [
                Text(
                  '${cartCubit.selectedCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Checkbox(
                  value: cartCubit.allSelected,
                  onChanged: cartCubit.toggleSelectAll,
                  checkColor: Colors.white,
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradientAppbar),
      ),
    );
  }
}
