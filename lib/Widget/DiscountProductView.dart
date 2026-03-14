import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shopping_app/Screens/ProductPageDetail.dart';
import 'package:shopping_app/Widget/ProductCard.dart';

class DiscountedProductsView extends StatelessWidget {
  final bool isAdmin;

  const DiscountedProductsView({Key? key, this.isAdmin = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('offer', isGreaterThan: 0);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        if (products.isEmpty) {
          return const Center(child: Text('لا يوجد منتجات بها خصم'));
        }

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

              final double cardHeight = (index % 2 == 0) ? 250.0 : 260.0;

              return ProductCard(
                productData: {'id': productId, ...product},
                productId: productId,
                heights: cardHeight,
                isAdmin: isAdmin,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(
                        productData: {'id': productId, ...product},
                        isAdmin: isAdmin,
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
