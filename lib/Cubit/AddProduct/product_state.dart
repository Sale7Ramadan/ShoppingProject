import 'dart:io';

class ProductState {
  final String? productName;
  final String? productPrice;
  final String? productDescription;
  final String? selectedCategory;
  final double? offerPercentage;

  final File? mainImageFile;
  final String? mainImageUrl;

  final List<File> subImagesFiles;
  final List<Map<int, int>> subImagesSizeQuantity;

  final List<Map<String, dynamic>> existingSubImages;

  final bool isSaving;

  ProductState({
    this.productName,
    this.productPrice,
    this.productDescription,
    this.selectedCategory,
    this.offerPercentage,
    this.mainImageFile,
    this.mainImageUrl,
    this.subImagesFiles = const [],
    this.subImagesSizeQuantity = const [],
    this.existingSubImages = const [],
    this.isSaving = false,
  });

  factory ProductState.initial() {
    return ProductState(
      productName: null,
      productPrice: null,
      productDescription: null,
      selectedCategory: null,
      offerPercentage: null,
      mainImageFile: null,
      mainImageUrl: null,
      subImagesFiles: [],
      subImagesSizeQuantity: [],
      existingSubImages: [],
      isSaving: false,
    );
  }

  ProductState copyWith({
    String? productName,
    String? productPrice,
    String? productDescription,
    String? selectedCategory,
    double? offerPercentage,
    File? mainImageFile,
    String? mainImageUrl,
    List<File>? subImagesFiles,
    List<Map<int, int>>? subImagesSizeQuantity,
    List<Map<String, dynamic>>? existingSubImages,
    bool? isSaving,
  }) {
    return ProductState(
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productDescription: productDescription ?? this.productDescription,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      offerPercentage: offerPercentage ?? this.offerPercentage,
      mainImageFile: mainImageFile ?? this.mainImageFile,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      subImagesFiles: subImagesFiles ?? this.subImagesFiles,
      subImagesSizeQuantity:
          subImagesSizeQuantity ?? this.subImagesSizeQuantity,
      existingSubImages: existingSubImages ?? this.existingSubImages,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
