import 'package:flutter/material.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/features/profile/views/profile_page.dart';
import 'package:shopping_app/features/cart/views/cart_page.dart';
import 'package:shopping_app/features/products/views/favorite_page.dart';
import 'package:shopping_app/core/views/call_us_page.dart';
import 'package:shopping_app/features/admin/views/admin_dashboard.dart';
import 'package:shopping_app/core/widgets/category_section.dart';
import 'package:shopping_app/core/helpers/app_functions.dart';
import 'package:shopping_app/core/widgets/simple_drawer_item.dart';
import 'package:shopping_app/features/products/widgets/all_product_view.dart';
import 'package:shopping_app/features/products/widgets/best_selling.dart';
import 'package:shopping_app/features/products/widgets/discount_product_view.dart';
import 'package:shopping_app/features/products/data/models/product_maps.dart';

class HomeMainView extends StatefulWidget {
  final bool isAdmin;
  static const String id = 'HomeMainPage';

  const HomeMainView({super.key, this.isAdmin = false});

  @override
  State<HomeMainView> createState() => _HomeMainViewState();
}

class _HomeMainViewState extends State<HomeMainView> {
  String selectedCategory = 'الجديدة';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('K-Shoes', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, ProfilePage.id);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'الأقسام',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              CategorySection(
                title: 'رجالي',
                icon: Icons.male,
                items: ['أحذية', 'صنادل'],
                onTap: (item) =>
                    goToCategory(context, 'رجالي $item', widget.isAdmin),
              ),
              CategorySection(
                title: 'نسائي',
                icon: Icons.female,
                items: ['حقائب', 'أحذية', 'صنادل'],
                onTap: (item) =>
                    goToCategory(context, 'نسائي $item', widget.isAdmin),
              ),
              CategorySection(
                title: 'أطفال',
                icon: Icons.child_care,
                items: ['بيبي', 'محير'],
                onTap: (item) =>
                    goToCategory(context, 'أطفال $item', widget.isAdmin),
              ),
              Divider(),
              SimpleDrawerItem(
                title: 'المفضلة',
                icon: Icons.favorite_border,
                onTap: () {
                  Navigator.pushNamed(context, FavoritePage.id);
                },
              ),
              SimpleDrawerItem(
                title: 'السلة',
                icon: Icons.shopping_cart_outlined,
                onTap: () {
                  Navigator.pushNamed(context, CartPage.id);
                },
              ),
              SimpleDrawerItem(
                title: 'الملف الشخصي',
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.pushNamed(context, ProfilePage.id);
                },
              ),
              SimpleDrawerItem(
                title: 'اتصل بنا',
                icon: Icons.call_made,
                onTap: () {
                  Navigator.pushNamed(context, ContactUsPage.id);
                },
              ),
              if (widget.isAdmin)
                SimpleDrawerItem(
                  title: 'لوحة التحكم',
                  icon: Icons.admin_panel_settings,
                  onTap: () {
                    Navigator.pushNamed(context, AdminDashboard.id);
                  },
                ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: categoriesHor.length,
              separatorBuilder: (_, __) => SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = categoriesHor[index];
                final isSelected = cat == selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = cat;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: selectedCategory == 'العروض'
                ? DiscountedProductsView(isAdmin: widget.isAdmin)
                : selectedCategory == 'الأكثر مبيعا'
                ? BestSellingProductsView(isAdmin: widget.isAdmin)
                : AllProductsView(
                    key: ValueKey(selectedCategory),
                    filterCategories: _getFilterCategories(selectedCategory),
                    isAdmin: widget.isAdmin,
                  ),
          ),
        ],
      ),
    );
  }

  List<String> _getFilterCategories(String category) {
    switch (category) {
      case 'رجالي':
        return ['رجالي أحذية', 'رجالي صنادل'];
      case 'نسائي':
        return ['نسائي صنادل', 'نسائي أحذية', 'نسائي حقائب'];
      case 'أطفال':
        return ['أطفال بيبي', 'أطفال محير'];
      default:
        return [];
    }
  }
}
