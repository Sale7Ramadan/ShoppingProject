import 'package:flutter/material.dart';
import 'package:shopping_app/features/admin/views/admin_dashboard.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/features/orders/views/order_page.dart';
import 'package:shopping_app/features/products/views/favorite_page.dart';
import 'package:shopping_app/features/products/views/home_main_view.dart';
import 'package:shopping_app/features/cart/views/cart_page.dart';

class HomePage extends StatefulWidget {
  final bool isAdmin;
  final bool isSuperAdmin;

  const HomePage({Key? key, this.isAdmin = false, this.isSuperAdmin = false})
    : super(key: key);

  static const String id = 'HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _navigateToPage(int index) {
    Navigator.pop(context); // إغلاق Drawer
    setState(() {
      _currentIndex = index;
    });
  }

  void _goHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeMainView(isAdmin: widget.isAdmin),
      FavoritePage(onBack: _goHome),
      OrdersPage(onBack: _goHome),
      CartPage(onBack: _goHome),
      if (widget.isAdmin) AdminDashboard(onBack: _goHome),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('المفضلة'),
                onTap: () => _navigateToPage(1),
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart_outlined),
                title: const Text('السلة'),
                onTap: () => _navigateToPage(3),
              ),
              // باقي العناصر...
              if (widget.isAdmin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('لوحة التحكم'),
                  onTap: () => _navigateToPage(4),
                ),
            ],
          ),
        ),
        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'المفضلة',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'الطلبات',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'السلة',
            ),
            if (widget.isAdmin)
              const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: 'الادمن',
              ),
          ],
        ),
      ),
    );
  }
}
