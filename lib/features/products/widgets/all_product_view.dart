import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shopping_app/features/products/views/product_page_detail.dart';
import 'package:shopping_app/features/products/widgets/product_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllProductsView extends StatefulWidget {
  final List<String>? filterCategories;
  final bool isAdmin;

  const AllProductsView({Key? key, this.filterCategories, this.isAdmin = false})
    : super(key: key);

  @override
  State<AllProductsView> createState() => _AllProductsViewState();
}

class _AllProductsViewState extends State<AllProductsView> {
  late Query query;
  List<String>? activeCategories;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_categories', categories);
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_categories');
    setState(() {
      activeCategories = widget.filterCategories ?? saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (activeCategories != null && activeCategories!.isNotEmpty) {
      query = FirebaseFirestore.instance
          .collection('products')
          .where('category', whereIn: activeCategories!);
      saveCategories(activeCategories!); // حفظها عند الاستخدام
    } else {
      query = FirebaseFirestore.instance
          .collection('products')
          .orderBy('created_at', descending: true)
          .limit(50);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        if (products.isEmpty) {
          return const Center(child: Text('لا يوجد منتجات في هذه الفئة'));
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

              final double cardHeight = (index % 2 == 0) ? 290.0 : 300.0;

              return ProductCard(
                productData: {'id': productId, ...product},
                productId: productId,
                heights: cardHeight,
                isAdmin: widget.isAdmin,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(
                        productData: {'id': productId, ...product},
                        isAdmin: widget.isAdmin,
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
