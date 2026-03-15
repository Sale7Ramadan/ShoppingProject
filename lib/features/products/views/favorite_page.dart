import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/features/products/widgets/product_card.dart';
import 'package:shopping_app/features/products/views/product_page_detail.dart';

class FavoritePage extends StatelessWidget {
  final VoidCallback? onBack;
  static const String id = 'FavoritePage';
  const FavoritePage({super.key, this.onBack});

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: const Text('المفضلة', style: TextStyle(color: Colors.white)),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: Text('يجب تسجيل الدخول لرؤية المفضلة')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا يوجد عناصر مفضلة حالياً'));
          }

          final favoriteDocs = snapshot.data!.docs;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: Future.wait(
              favoriteDocs.map((favDoc) async {
                final productId = favDoc.id;
                final productDoc = await FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .get();
                if (productDoc.exists) {
                  final productData = productDoc.data()!;
                  productData['id'] = productDoc.id;
                  return productData;
                }
                return <String, dynamic>{};
              }),
            ),
            builder: (context, productsSnapshot) {
              if (productsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final products =
                  productsSnapshot.data
                      ?.whereType<Map<String, dynamic>>()
                      .toList() ??
                  [];

              if (products.isEmpty) {
                return const Center(child: Text('لا يوجد عناصر مفضلة حالياً'));
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final productId = product['id'];

                    return ProductCard(
                      productData: product,
                      productId: productId,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ProductDetailsPage.id,
                          arguments: product,
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
