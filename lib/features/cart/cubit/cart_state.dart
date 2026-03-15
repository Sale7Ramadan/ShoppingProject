class CartState {
  final Map<String, Map<String, dynamic>> items;
  final Map<String, bool> selected;
  final bool loading;
  final bool isPlacingOrder; // ✅ جديد

  CartState({
    required this.items,
    required this.selected,
    required this.loading,
    this.isPlacingOrder = false, // ✅ جديد
  });

  CartState copyWith({
    Map<String, Map<String, dynamic>>? items,
    Map<String, bool>? selected,
    bool? loading,
    bool? isPlacingOrder, // ✅ جديد
  }) {
    return CartState(
      items: items ?? this.items,
      selected: selected ?? this.selected,
      loading: loading ?? this.loading,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder, // ✅ جديد
    );
  }
}
