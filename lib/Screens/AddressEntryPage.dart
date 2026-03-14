import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/Constant.dart';

class AddressEntryPage extends StatefulWidget {
  static const String id = 'enterAddress';

  const AddressEntryPage({Key? key}) : super(key: key);

  @override
  State<AddressEntryPage> createState() => _AddressEntryPageState();
}

class _AddressEntryPageState extends State<AddressEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      final address = data['address'] as Map<String, dynamic>?;

      if (address != null) {
        _cityController.text = address['city'] ?? '';
        _neighborhoodController.text = address['neighborhood'] ?? '';
        _streetController.text = address['street'] ?? '';
      }

      if (data['phone'] != null) {
        _phoneController.text = data['phone'];
      }
    }

    setState(() {
      _dataLoaded = true;
    });
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'address': {
            'city': _cityController.text.trim(),
            'neighborhood': _neighborhoodController.text.trim(),
            'street': _streetController.text.trim(),
          },
          'phone': _phoneController.text.trim(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حفظ العنوان ورقم الهاتف بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الحفظ، حاول مرة أخرى')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataLoaded) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'أدخل عنوان الشحن',
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('أدخل عنوان الشحن', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'الرجاء إدخال العنوان الكامل ورقم الهاتف:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 24),

              // المدينة
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'المدينة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال المدينة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // الحي
              TextFormField(
                controller: _neighborhoodController,
                decoration: InputDecoration(
                  labelText: 'الحي',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.home_work),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال الحي';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // الشارع
              TextFormField(
                controller: _streetController,
                decoration: InputDecoration(
                  labelText: 'الشارع',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.streetview),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال الشارع';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  if (!RegExp(r'^\+?\d{7,15}$').hasMatch(value.trim())) {
                    return 'الرجاء إدخال رقم هاتف صالح';
                  }
                  return null;
                },
              ),

              SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        'حفظ العنوان',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
