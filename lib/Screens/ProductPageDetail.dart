import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/Constant.dart';
import 'package:shopping_app/Cubit/Product Detail/product_detail_state.dart';
import 'package:shopping_app/Cubit/Product Detail/product_details_cubit.dart';
import 'package:shopping_app/helper/Function.dart';
import 'package:shopping_app/services/CartService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/services/ProductMaps.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> productData;
  final bool isAdmin;
  static const String id = 'ProductPageDetail';

  ProductDetailsPage({
    super.key,
    required this.productData,
    this.isAdmin = false,
  });

  final quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailsCubit(productData),
      child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          final cubit = context.read<ProductDetailsCubit>();
          final subs = productData['sub_images'] ?? [];
          final category = productData['category'] ?? '';

          // ✅ تعديل: تحديد الفئات التي لا تحتوي على مقاسات
          final List<String> categoriesWithoutSizes = ['نسائي حقائب'];
          final bool hasSizes = !categoriesWithoutSizes.contains(category);

          // ✅ تعديل: جلب الصورة الفرعية المختارة
          Map<String, dynamic>? matchedSubImage;
          for (var sub in subs) {
            if (sub['image'] == state.selectedSubImage) {
              matchedSubImage = sub;
              break;
            }
          }

          // ✅ تعديل: حساب المخزون إن لم يكن هناك مقاسات
          int? subImageStock;
          if (!hasSizes && matchedSubImage != null) {
            final sizesQuantities =
                matchedSubImage['sizes_quantities'] as Map<String, dynamic>?;
            if (sizesQuantities != null) {
              subImageStock = sizesQuantities.values.fold<int>(
                0,
                (sum, val) => sum + (val as int),
              );
            }
          }

          return Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Text(
                productData['name'] ?? 'تفاصيل المنتج',
                style: const TextStyle(color: Colors.white),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      productData['image'],
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    productData['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${productData['price']} د.ع',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    productData['description'] ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 12),

                  if (subs.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: subs.length,
                        itemBuilder: (c, i) {
                          final img = subs[i]['image'] ?? '';
                          final sel = state.selectedSubImage == img;
                          return GestureDetector(
                            onTap: () {
                              cubit.selectSubImage(img);
                              quantityController.clear();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: sel ? Colors.blue : Colors.transparent,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  img,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 20),

                  if (!hasSizes &&
                      state.selectedSubImage != null &&
                      subImageStock != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'المتوفر: $subImageStock قطعة',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  if (hasSizes && state.sizeQuantities.isNotEmpty) ...[
                    const Text(
                      'اختر المقاس:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: state.sizeQuantities.keys.map((size) {
                        final isSelected = state.selectedSize == size;
                        return FilterChip(
                          label: Text(size.toString()),
                          selected: isSelected,
                          onSelected: (_) => cubit.selectSize(size),
                        );
                      }).toList(),
                    ),
                  ],

                  if (hasSizes && state.selectedSizeStock != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'المتوفر: ${state.selectedSizeStock} قطعة',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الكمية المطلوبة',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: ElevatedButton.icon(
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                            ),
                      label: state.isLoading
                          ? const Text(
                              'جاري المعالجة...',
                              style: TextStyle(color: Colors.white),
                            )
                          : const Text(
                              'إضافة إلى السلة',
                              style: TextStyle(color: Colors.white),
                            ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              final qty = int.tryParse(quantityController.text);

                              if (hasSizes &&
                                  (state.selectedSize == null ||
                                      state.selectedSubImage == null)) {
                                WarrningMessage(
                                  context,
                                  '❌ الرجاء اختيار صورة ومقاس',
                                );
                                return;
                              }

                              if (state.selectedSubImage == null) {
                                WarrningMessage(
                                  context,
                                  '❌ الرجاء اختيار صورة',
                                );
                                return;
                              }

                              if (qty == null || qty <= 0) {
                                WarrningMessage(
                                  context,
                                  '❌ الرجاء إدخال كمية صحيحة',
                                );
                                return;
                              }

                              if (hasSizes &&
                                  state.selectedSizeStock != null &&
                                  qty > state.selectedSizeStock!) {
                                WarrningMessage(
                                  context,
                                  '❌ الكمية المطلوبة غير متوفرة في المخزون',
                                );
                                return;
                              }

                              if (!hasSizes &&
                                  subImageStock != null &&
                                  qty > subImageStock) {
                                WarrningMessage(
                                  context,
                                  '❌ الكمية المطلوبة غير متوفرة في المخزون',
                                );
                                return;
                              }

                              cubit.setLoading(true);
                              try {
                                await CartService.addToCart(
                                  productId: productData['id'],
                                  productData: {
                                    ...productData,
                                    'image': state.selectedSubImage!,
                                  },
                                  selectedSizes:
                                      hasSizes && state.selectedSize != null
                                      ? [state.selectedSize!]
                                      : [],
                                  quantitiesPerSize:
                                      hasSizes && state.selectedSize != null
                                      ? {state.selectedSize!: qty}
                                      : {},
                                  quantity: qty,
                                );
                                WarrningMessage(
                                  context,
                                  '✅ تمت إضافة المنتج إلى السلة',
                                );
                              } catch (e) {
                                WarrningMessage(
                                  context,
                                  '❌ حدث خطأ أثناء الإضافة إلى السلة',
                                );
                              }
                              cubit.setLoading(false);
                            },
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isAdmin)
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          'حذف المنتج',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('تأكيد الحذف'),
                              content: const Text(
                                'هل أنت متأكد من حذف هذا المنتج؟',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('products')
                                  .doc(productData['id'])
                                  .delete();
                              WarrningMessage(context, '✅ تم حذف المنتج بنجاح');
                              Navigator.of(context).pop();
                            } catch (e) {
                              WarrningMessage(
                                context,
                                '❌ حدث خطأ أثناء حذف المنتج',
                              );
                            }
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
