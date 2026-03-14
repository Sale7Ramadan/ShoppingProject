import 'package:flutter/material.dart';
import 'package:shopping_app/Admin/AddProductPage.dart';
import 'package:shopping_app/Services/favorite_service.dart';

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String productId;
  final VoidCallback onTap;
  double? heights;
  final bool? isAdmin;

  ProductCard({
    super.key,
    required this.productData,
    required this.productId,
    required this.onTap,
    this.heights,
    this.isAdmin = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkIfFav();
  }

  Future<void> checkIfFav() async {
    final result = await FavoriteService.checkIfFavorite(widget.productId);
    if (mounted) {
      setState(() => isFavorite = result);
    }
  }

  Future<void> toggleFavorite() async {
    await FavoriteService.toggleFavorite(widget.productId, widget.productData);
    if (!mounted) return;
    setState(() => isFavorite = !isFavorite);
  }

  void navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(
          productData: widget.productData,
          productId: widget.productId,
          isEditing: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double productPrice =
        widget.productData['original_price']?.toDouble() ?? 0; // السعر الأصلي
    double? offerPercentage = widget.productData['offer']?.toDouble();

    // حساب السعر النهائي بعد الخصم
    double finalPrice = (offerPercentage != null && offerPercentage > 0)
        ? productPrice * (1 - offerPercentage / 100)
        : productPrice;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: widget.heights,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      widget.productData['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  if (offerPercentage != null && offerPercentage > 0)
                    Positioned(
                      top: 8,
                      left: -30,
                      child: Transform.rotate(
                        angle: -0.785,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 40,
                          ),
                          color: Colors.red,
                          child: Text(
                            '${offerPercentage.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (widget.isAdmin ?? false)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddProductPage(
                                productData: widget.productData,
                                productId: widget.productId,
                                isEditing: true,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.blueAccent,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: toggleFavorite,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.productData['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${finalPrice.toInt()} د.ع',
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (offerPercentage != null && offerPercentage > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '${productPrice.toInt()}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.productData['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
