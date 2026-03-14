import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/Admin/AddProductPage.dart';
import 'package:shopping_app/Admin/AdminOrderPage.dart';
import 'package:shopping_app/Admin/ManageAdminPage.dart';
import 'package:shopping_app/Admin/UserProplemPage.dart';
import 'package:shopping_app/Constant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopping_app/Cubit/AdminOrder/OrderAdminCubit.dart';

class AdminDashboard extends StatefulWidget {
  final VoidCallback? onBack;
  static const String id = 'AdminDashboard';

  const AdminDashboard({super.key, this.onBack});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'لوحة التحكم',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.grey[100],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "خيارات الإدارة",
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "إدارة المنتجات، الطلبات، المستخدمين والمزيد",
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              _buildDashboardCardModern(
                context: context,
                title: 'إضافة منتج جديد',
                icon: Icons.add_box,
                color: Colors.deepPurple,
                routeName: AddProductPage.id,
              ),
              _buildDashboardCardModern(
                context: context,
                title: 'إدارة الطلبات',
                icon: Icons.shopping_cart,
                color: Colors.orange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => OrdersAdminCubit()
                          ..fetchShippingFee()
                          ..listenOrders(filterStatus: 'all'),
                        child: AdminOrdersPage(),
                      ),
                    ),
                  );
                },
              ),
              _buildDashboardCardModern(
                context: context,
                title: 'مشاكل المستخدمين',
                icon: Icons.report_problem,
                color: Colors.redAccent,
                routeName: UserProblemPage.id,
              ),
              _buildDashboardCardModern(
                context: context,
                title: 'إضافة أدمن',
                icon: Icons.admin_panel_settings,
                color: Colors.teal,
                routeName: ManageAdminsPage.id,
              ),
              _buildDashboardCardModern(
                context: context,
                title: 'أجور الشحن',
                icon: Icons.local_shipping,
                color: Colors.blue,
                onPressed: () => _showShippingDialog(context),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AddProductPage.id);
        },
        backgroundColor: kPrimaryColor,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("منتج جديد", style: GoogleFonts.cairo(color: Colors.white)),
      ),
    );
  }

  Widget _buildDashboardCardModern({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    String? routeName,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap:
          onPressed ??
          () {
            if (routeName != null && routeName.isNotEmpty) {
              Navigator.pushNamed(context, routeName);
            }
          },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showShippingDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "تحديث أجور الشحن",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("الرجاء إدخال أجور الشحن الجديدة"),
              SizedBox(height: 12),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "أجور الشحن",
                  prefixIcon: Icon(Icons.local_shipping),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("إلغاء", style: GoogleFonts.cairo()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text("حفظ", style: GoogleFonts.cairo()),
              onPressed: () async {
                final value = double.tryParse(_controller.text);
                if (value != null) {
                  await saveShippingFee(value);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("تم حفظ أجور الشحن بنجاح")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("يرجى إدخال رقم صحيح")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveShippingFee(double fee) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    await _firestore.collection('settings').doc('shipping_fee').set({
      'fee': fee,
    }, SetOptions(merge: true));
  }
}
