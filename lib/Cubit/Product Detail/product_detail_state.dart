class ProductDetailsState {
  final String? selectedSubImage;
  final Map<int, int> sizeQuantities;
  final int? selectedSize;
  final int? selectedSizeStock;
  final int likeCount;
  final bool isLiked;
  final bool isLoading;

  ProductDetailsState({
    this.selectedSubImage,
    this.sizeQuantities = const {},
    this.selectedSize,
    this.selectedSizeStock,
    this.likeCount = 0,
    this.isLiked = false,
    this.isLoading = false,
  });

  ProductDetailsState copyWith({
    String? selectedSubImage,
    Map<int, int>? sizeQuantities,
    int? selectedSize,
    int? selectedSizeStock,
    int? likeCount,
    bool? isLiked,
    bool? isLoading,
  }) {
    return ProductDetailsState(
      selectedSubImage: selectedSubImage ?? this.selectedSubImage,
      sizeQuantities: sizeQuantities ?? this.sizeQuantities,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedSizeStock: selectedSizeStock ?? this.selectedSizeStock,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
