import 'package:flutter/material.dart';
import 'package:shopping_app/Constant.dart';
import 'package:shopping_app/Screens/ProfilePage.dart';
import 'package:shopping_app/Screens/CartPage.dart';
import 'package:shopping_app/Screens/FavoritePage.dart';
import 'package:shopping_app/Screens/CallUsPage.dart';
import 'package:shopping_app/Admin/AdminDashboard.dart';
import 'package:shopping_app/helper/CategorySection.dart';
import 'package:shopping_app/helper/Function.dart';
import 'package:shopping_app/helper/SimpleDrawerItem.dart';
import 'package:shopping_app/Widget/AllProductView.dart';
import 'package:shopping_app/Widget/BestSelling.dart';
import 'package:shopping_app/Widget/DiscountProductView.dart';
import 'package:shopping_app/services/ProductMaps.dart';

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
