import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shopping_app/Screens/ProductPageDetail.dart';
import 'package:shopping_app/Widget/ProductCard.dart';

class BestSellingProductsView extends StatefulWidget {
  final bool isAdmin;

  const BestSellingProductsView({Key? key, this.isAdmin = false})
    : super(key: key);

  @override
  State<BestSellingProductsView> createState() =>
      _BestSellingProductsViewState();
}

class _BestSellingProductsViewState extends State<BestSellingProductsView> {
  Map<String, int> productCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBestSellers();
  }

  Future<void> fetchBestSellers() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, int> counts = {};

    try {
      final ordersSnapshot = await firestore
          .collection('adminOrders')
          .where('status', isEqualTo: 'Success')
          .get();

      for (var orderDoc in ordersSnapshot.docs) {
        final data = orderDoc.data();
        String productId = data['id'];
        int quantity = data['quantity'] ?? 1;

        counts[productId] = (counts[productId] ?? 0) + quantity;
      }

      // فلترة المنتجات حسب شرط الكمية >= 20
      counts.removeWhere((productId, quantity) => quantity < 20);

      setState(() {
        productCounts = counts;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching best sellers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productCounts.isEmpty) {
      return const Center(child: Text('لا يوجد مبيعات حتى الآن'));
    }

    // ترتيب المنتجات حسب عدد المبيعات
    final sortedProductIds = productCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topProductIds = sortedProductIds.take(50).map((e) => e.key).toList();

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: topProductIds)
          .get(),
      builder: (context, productSnapshot) {
        if (!productSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = productSnapshot.data!.docs;

        products.sort(
          (a, b) => topProductIds
              .indexOf(a.id)
              .compareTo(topProductIds.indexOf(b.id)),
        );

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;

              final double cardHeight = (index % 2 == 0) ? 250.0 : 270.0;

              return ProductCard(
                productData: {'id': productId, ...product},
                productId: productId,
                heights: cardHeight,
                isAdmin: widget.isAdmin, // تمرير isAdmin
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(
                        productData: {'id': productId, ...product},
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
