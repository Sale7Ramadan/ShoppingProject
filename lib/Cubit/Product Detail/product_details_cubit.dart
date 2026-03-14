import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/Cubit/Product%20Detail/product_detail_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final Map<String, dynamic> productData;

  ProductDetailsCubit(this.productData) : super(ProductDetailsState()) {
    _init();
  }

  void _init() {
    final likeCount = productData['likeCount'] ?? 0;
    final isLiked = productData['isLiked'] ?? false;

    if (productData['sub_images'] != null &&
        productData['sub_images'].isNotEmpty) {
      final firstImage = productData['sub_images'][0]['image'];
      emit(
        state.copyWith(
          selectedSubImage: firstImage,
          likeCount: likeCount,
          isLiked: isLiked,
        ),
      );
      _loadSubImageData(firstImage);
    }
  }

  void _loadSubImageData(String selectedImage) {
    final subs = productData['sub_images'];
    final idx = subs.indexWhere((s) => s['image'] == selectedImage);
    if (idx != -1) {
      final rawSizesQuantities = subs[idx]['sizes_quantities'] ?? {};
      final Map<int, int> sizeQuantities = {};
      rawSizesQuantities.forEach((key, value) {
        final intKey = int.tryParse(key.toString());
        if (intKey == null) return;

        sizeQuantities[intKey] = value as int;
      });

      emit(
        state.copyWith(
          selectedSubImage: selectedImage,
          sizeQuantities: sizeQuantities,
          selectedSize: null,
          selectedSizeStock: null,
        ),
      );
    }
  }

  void selectSubImage(String image) {
    _loadSubImageData(image);
  }

  void selectSize(int size) {
    final stock = state.sizeQuantities[size];
    emit(state.copyWith(selectedSize: size, selectedSizeStock: stock));
  }

  Future<void> toggleLike() async {
    final newLikeStatus = !state.isLiked;
    final newLikeCount = newLikeStatus
        ? state.likeCount + 1
        : state.likeCount - 1;

    emit(state.copyWith(isLiked: newLikeStatus, likeCount: newLikeCount));

    await FirebaseFirestore.instance
        .collection('products')
        .doc(productData['id'])
        .update({'likeCount': newLikeCount, 'isLiked': newLikeStatus});
  }

  void setLoading(bool loading) {
    emit(state.copyWith(isLoading: loading));
  }
}
