import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shopping_app/Cubit/AddProduct/product_state.dart';

import 'package:shopping_app/helper/Function.dart';
import 'package:shopping_app/services/ProductMaps.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductState());

  void updateName(String name) {
    emit(state.copyWith(productName: name));
  }

  void updatePrice(String price) {
    emit(state.copyWith(productPrice: price));
  }

  void updateDescription(String description) {
    emit(state.copyWith(productDescription: description));
  }

  void updateCategory(String? category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void updateOffer(String val) {
    double? offerVal = double.tryParse(val);
    emit(state.copyWith(offerPercentage: offerVal));
  }

  void setMainImage(File? file) {
    emit(state.copyWith(mainImageFile: file, mainImageUrl: null));
  }

  void setMainImageUrl(String url) {
    emit(state.copyWith(mainImageUrl: url));
  }

  void addSubImage(File image) {
    final newSubImages = List<File>.from(state.subImagesFiles)..add(image);
    final newSizeQuantity = List<Map<int, int>>.from(
      state.subImagesSizeQuantity,
    )..add({});

    emit(
      state.copyWith(
        subImagesFiles: newSubImages,
        subImagesSizeQuantity: newSizeQuantity,
      ),
    );
  }

  void resetProductData() {
    emit(ProductState.initial());
  }

  void setSaving(bool saving) {
    emit(state.copyWith(isSaving: saving));
  }

  Future<String> uploadImage(File imageFile) async {
    final cloudName = 'doemui1fd';
    final uploadPreset = 'unsigned_preset';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final mimeTypeData = lookupMimeType(imageFile.path)!.split('/');

    final imageUploadRequest = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

    final streamedResponse = await imageUploadRequest.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['secure_url'];
    } else {
      throw Exception('فشل رفع الصورة: ${response.statusCode}');
    }
  }

  void loadProductForEdit({
    required String productName,
    required String productPrice,
    String? productDescription,
    String? selectedCategory,
    double? offerPercentage,
    String? mainImageUrl,
    List<Map<String, dynamic>>? existingSubImages,
  }) {
    emit(
      ProductState(
        productName: productName,
        productPrice: productPrice,
        productDescription: productDescription,
        selectedCategory: selectedCategory,
        offerPercentage: offerPercentage,
        mainImageFile: null,
        mainImageUrl: mainImageUrl,
        subImagesFiles: [],
        subImagesSizeQuantity: [],
        existingSubImages: existingSubImages ?? [],
        isSaving: false,
      ),
    );
  }

  void loadExistingSubImages(List<Map<String, dynamic>> existingImages) {
    emit(state.copyWith(existingSubImages: existingImages));
  }

  void removeExistingSubImage(int index) {
    final updatedExisting = List<Map<String, dynamic>>.from(
      state.existingSubImages,
    );
    if (index >= 0 && index < updatedExisting.length) {
      updatedExisting.removeAt(index);
      emit(state.copyWith(existingSubImages: updatedExisting));
    }
  }

  void removeSubImage(int index) {
    final subImages = List<File>.from(state.subImagesFiles);
    final sizeQuantities = List<Map<int, int>>.from(
      state.subImagesSizeQuantity,
    );

    if (index >= 0 && index < subImages.length) {
      subImages.removeAt(index);
      sizeQuantities.removeAt(index);
      emit(
        state.copyWith(
          subImagesFiles: subImages,
          subImagesSizeQuantity: sizeQuantities,
        ),
      );
    }
  }

  // تحديث البيانات للصور الفرعية الجديدة
  void updateSubImageData(int index, Map<int, int> sizeQuantityMap) {
    final updated = List<Map<int, int>>.from(state.subImagesSizeQuantity);
    if (index >= 0 && index < updated.length) {
      updated[index] = sizeQuantityMap;
      emit(state.copyWith(subImagesSizeQuantity: updated));
    }
  }

  // تحديث البيانات للصور الفرعية الموجودة
  void updateExistingSubImageData(int index, Map<int, int> sizeQuantityMap) {
    final updatedExisting = List<Map<String, dynamic>>.from(
      state.existingSubImages,
    );

    if (index >= 0 && index < updatedExisting.length) {
      final sizeMapStringKeys = sizeQuantityMap.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      updatedExisting[index] = {
        ...updatedExisting[index],
        'sizes_quantities': sizeMapStringKeys,
      };

      emit(state.copyWith(existingSubImages: updatedExisting));
    }
  }

  void updateExistingSizesQuantities(
    int index,
    Map<int, int> updatedSizesQuantities,
  ) {
    final updatedExisting = List<Map<String, dynamic>>.from(
      state.existingSubImages,
    );

    if (index >= 0 && index < updatedExisting.length) {
      final updatedMapStringKeys = updatedSizesQuantities.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      updatedExisting[index] = {
        ...updatedExisting[index],
        'sizes_quantities': updatedMapStringKeys,
      };

      emit(state.copyWith(existingSubImages: updatedExisting));
    }
  }

  Future<void> saveProduct({
    required GlobalKey<FormState> formKey,
    required BuildContext context,
    required bool isEditing,
    required String? productId,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (state.mainImageFile == null && state.mainImageUrl == null) {
      WarrningMessage(context, 'يرجى إضافة صورة رئيسية');
      return;
    }

    if (state.subImagesFiles.isEmpty && state.existingSubImages.isEmpty) {
      WarrningMessage(context, 'يرجى إضافة صورة فرعية واحدة على الأقل');
      return;
    }

    emit(state.copyWith(isSaving: true));

    try {
      // تحقق من الصور الفرعية الجديدة
      for (int i = 0; i < state.subImagesFiles.length; i++) {
        final sizeMap = state.subImagesSizeQuantity[i];
        if (sizeMap.isEmpty || sizeMap.values.every((q) => q <= 0)) {
          WarrningMessage(
            context,
            'يرجى إدخال كميات للمقاسات في الصورة الفرعية رقم ${state.existingSubImages.length + i + 1}',
          );
          emit(state.copyWith(isSaving: false));
          return;
        }

        final currentCategory = state.selectedCategory ?? '';
        final shouldCheckSizes = !categoriesWithoutSizes.contains(
          currentCategory,
        );
        if (shouldCheckSizes && sizeMap.keys.isEmpty) {
          WarrningMessage(
            context,
            'يرجى اختيار المقاسات للون رقم ${state.existingSubImages.length + i + 1}',
          );
          emit(state.copyWith(isSaving: false));
          return;
        }
      }

      // تحقق من الصور الفرعية القديمة
      for (int i = 0; i < state.existingSubImages.length; i++) {
        final rawMap = Map<String, dynamic>.from(
          state.existingSubImages[i]['sizes_quantities'] ?? {},
        );
        final sizeMap = rawMap.map(
          (key, value) => MapEntry(int.parse(key), value as int),
        );

        if (sizeMap.isEmpty || sizeMap.values.every((q) => q <= 0)) {
          WarrningMessage(
            context,
            'يرجى إدخال كميات للمقاسات في اللون الموجود رقم ${i + 1}',
          );
          emit(state.copyWith(isSaving: false));
          return;
        }

        final currentCategory = state.selectedCategory ?? '';
        final shouldCheckSizes = !categoriesWithoutSizes.contains(
          currentCategory,
        );
        if (shouldCheckSizes && sizeMap.keys.isEmpty) {
          WarrningMessage(
            context,
            'يرجى اختيار المقاسات في اللون الموجود رقم ${i + 1}',
          );
          emit(state.copyWith(isSaving: false));
          return;
        }
      }

      // رفع الصورة الرئيسية
      final mainImageUrl =
          state.mainImageUrl ?? await uploadImage(state.mainImageFile!);

      // رفع الصور الفرعية بالتوازي باستخدام Future.wait
      List<Future<Map<String, dynamic>>> uploadTasks = [];

      for (int i = 0; i < state.subImagesFiles.length; i++) {
        final file = state.subImagesFiles[i];
        final sizeMap = state.subImagesSizeQuantity[i];

        final Map<String, int> sizeMapStringKeys = sizeMap.map(
          (key, value) => MapEntry(key.toString(), value),
        );

        uploadTasks.add(
          uploadImage(file).then(
            (imageUrl) => {
              'image': imageUrl,
              'sizes_quantities': sizeMapStringKeys,
            },
          ),
        );
      }

      final List<Map<String, dynamic>> subImagesWithData = await Future.wait(
        uploadTasks,
      );

      // دمج الصور الجديدة مع القديمة
      final updatedExistingSubImages = List<Map<String, dynamic>>.from(
        state.existingSubImages,
      );
      final allSubImages = [...updatedExistingSubImages, ...subImagesWithData];

      final originalPrice = double.parse(state.productPrice!);
      final finalPrice =
          (state.offerPercentage != null && state.offerPercentage! > 0)
          ? originalPrice * (1 - state.offerPercentage! / 100)
          : originalPrice;

      final productData = {
        'name': state.productName,
        'price': finalPrice,
        'original_price': originalPrice,
        'offer': state.offerPercentage ?? 0,
        'description': state.productDescription,
        'image': mainImageUrl,
        'category': state.selectedCategory,
        'sub_images': allSubImages,
        'created_at': FieldValue.serverTimestamp(),
      };

      final docRef = isEditing
          ? FirebaseFirestore.instance.collection('products').doc(productId)
          : FirebaseFirestore.instance.collection('products').doc();

      await docRef.set(productData);

      WarrningMessage(context, 'تم حفظ المنتج بنجاح');
      Navigator.pop(context);

      emit(state.copyWith(subImagesFiles: [], subImagesSizeQuantity: []));
    } catch (e) {
      WarrningMessage(context, 'حدث خطأ: $e');
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }
}
