import 'package:flutter/material.dart';
import 'package:shopping_app/Constant.dart';
import 'package:shopping_app/Cubit/AddProduct/product_state.dart';

class MainImagePicker extends StatelessWidget {
  final ProductState state;
  final VoidCallback onPick;

  const MainImagePicker({Key? key, required this.state, required this.onPick})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الصورة الرئيسية:', style: TextStyle(color: Colors.black)),
        const SizedBox(height: 8),

        (state.mainImageFile == null && state.mainImageUrl == null)
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.image, color: Colors.white),
                  label: Text(
                    'اختر صورة',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  onPressed: onPick,
                ),
              )
            : Stack(
                children: [
                  // عرض الصورة
                  state.mainImageFile != null
                      ? Image.file(
                          state.mainImageFile!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          state.mainImageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onPick,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
