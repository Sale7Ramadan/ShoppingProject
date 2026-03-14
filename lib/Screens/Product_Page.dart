import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/Constant.dart';
import 'package:shopping_app/Screens/ProductPageDetail.dart';
import 'package:shopping_app/Widget/ProductCard.dart';

class ProductPage extends StatelessWidget {
  final bool isAdmin;
  ProductPage({super.key, this.isAdmin = false});

  static const String id = 'ProductPage';

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(category, style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('لا يوجد منتجات في هذا القسم'));
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final product = doc.data() as Map<String, dynamic>;
              final productId = doc.id;

              return ProductCard(
                productData: product,
                productId: productId,
                isAdmin: isAdmin,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(
                        isAdmin: isAdmin,
                        productData: {
                          ...product,
                          'id': productId, // أضفنا الـ ID للبيانات
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
