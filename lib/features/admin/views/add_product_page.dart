import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/features/admin/cubit/product_cubit.dart';
import 'package:shopping_app/features/admin/cubit/product_state.dart';
import 'package:shopping_app/core/widgets/form_text_feild.dart';
import 'package:shopping_app/features/admin/widgets/main_image_picker.dart';
import 'package:shopping_app/features/admin/widgets/sub_images_list.dart';
import 'package:shopping_app/features/products/data/models/product_maps.dart';

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? productData;
  final String? productId;
  final bool isEditing;

  const AddProductPage({
    this.productData,
    this.productId,
    this.isEditing = false,
    Key? key,
  }) : super(key: key);

  static const String id = 'AddProductPage';

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> existingSubImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.productData != null) {
      _loadProductData(widget.productData!);
    } else {
      context.read<ProductCubit>().resetProductData();
      existingSubImages = [];
    }
  }

  @override
  void didUpdateWidget(covariant AddProductPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEditing &&
        widget.productData != null &&
        widget.productData != oldWidget.productData) {
      _loadProductData(widget.productData!);
    } else if (!widget.isEditing) {
      context.read<ProductCubit>().resetProductData();
      setState(() {
        existingSubImages = [];
      });
    }
  }

  void _loadProductData(Map<String, dynamic> data) {
    final cubit = context.read<ProductCubit>();

    cubit
      ..updateName(data['name'] ?? '')
      ..updatePrice(
        data['original_price']?.toString() ?? data['price']?.toString() ?? '',
      )
      ..updateDescription(data['description'] ?? '')
      ..updateCategory(data['category'])
      ..updateOffer(data['offer']?.toString() ?? '')
      ..setMainImageUrl(data['image']);

    final List<Map<String, dynamic>> existingSubImages =
        List<Map<String, dynamic>>.from(data['sub_images'] ?? []);

    List<Map<int, int>> processedSizesQuantities = [];

    for (var subImage in existingSubImages) {
      final sizesQuantitiesRaw = Map<String, dynamic>.from(
        subImage['sizes_quantities'] ?? {},
      );

      final Map<int, int> sizesQuantities = {};
      sizesQuantitiesRaw.forEach((key, value) {
        final size = int.parse(key);
        final qty = value as int;
        sizesQuantities[size] = qty;
      });

      processedSizesQuantities.add(sizesQuantities);
    }

    cubit.loadExistingSubImages(existingSubImages);

    for (int i = 0; i < processedSizesQuantities.length; i++) {
      cubit.updateExistingSizesQuantities(i, processedSizesQuantities[i]);
    }
  }

  bool _isPickingImage = false;

  Future pickMainImage() async {
    if (_isPickingImage) return;

    _isPickingImage = true;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        context.read<ProductCubit>().setMainImage(File(pickedFile.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      _isPickingImage = false;
    }
  }

  Future pickSubImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      for (var file in pickedFiles) {
        context.read<ProductCubit>().addSubImage(File(file.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          widget.isEditing ? 'تعديل المنتج' : 'إضافة منتج',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  ProductTextField(
                    label: 'اسم المنتج',
                    initialValue: state.productName,
                    onChanged: context.read<ProductCubit>().updateName,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'يرجى إدخال الاسم' : null,
                  ),
                  const SizedBox(height: 16),
                  ProductTextField(
                    label: 'السعر',
                    keyboardType: TextInputType.number,
                    initialValue: state.productPrice,
                    onChanged: context.read<ProductCubit>().updatePrice,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'يرجى إدخال السعر';
                      if (double.tryParse(val) == null)
                        return 'يرجى إدخال رقم صحيح';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ProductTextField(
                    label: 'الوصف',
                    initialValue: state.productDescription,
                    onChanged: context.read<ProductCubit>().updateDescription,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'يرجى إدخال الوصف' : null,
                  ),
                  const SizedBox(height: 16),
                  ProductTextField(
                    label: 'نسبة الخصم (%)',
                    keyboardType: TextInputType.number,
                    initialValue: state.offerPercentage?.toString(),
                    onChanged: context.read<ProductCubit>().updateOffer,
                    validator: (val) {
                      if (val == null || val.isEmpty) return null;
                      final numVal = double.tryParse(val);
                      if (numVal == null || numVal < 0 || numVal > 100)
                        return 'ادخل نسبة بين 0 و 100';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: state.selectedCategory,
                    decoration: const InputDecoration(labelText: 'اختر الفئة'),
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: context.read<ProductCubit>().updateCategory,
                    validator: (val) =>
                        val == null ? 'يرجى اختيار الفئة' : null,
                  ),
                  const SizedBox(height: 16),

                  MainImagePicker(state: state, onPick: pickMainImage),
                  const SizedBox(height: 16),
                  const Text('الوان المنتج:'),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('اختر الوان المنتج'),
                    onPressed: pickSubImages,
                  ),
                  const SizedBox(height: 16),
                  SubImagesList(
                    existingSubImages: state.existingSubImages,
                    newSubImages: state.subImagesFiles,
                    newSubImagesSizes: state.subImagesSizeQuantity,
                    category: state.selectedCategory ?? '',
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: state.isSaving
                        ? null
                        : () {
                            context.read<ProductCubit>().saveProduct(
                              formKey: formKey,
                              context: context,
                              isEditing: widget.isEditing,
                              productId: widget.productId,
                            );
                          },
                    child: state.isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.isEditing ? 'تحديث المنتج' : 'إضافة المنتج',
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
