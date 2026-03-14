import 'dart:async';
import 'package:flutter/material.dart';

class CategorySlider extends StatefulWidget {
  final Function(String title)? onCategoryTap;

  const CategorySlider({super.key, this.onCategoryTap});

  @override
  State<CategorySlider> createState() => _CategorySliderState();
}

class _CategorySliderState extends State<CategorySlider> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, String>> categories = [
    {'title': 'أحذية رجالي', 'image': 'Assets/Images/Backpak.jpg'},
    {'title': 'أحذية نسائي', 'image': 'Assets/Images/Backpak.jpg'},
    {'title': 'حقائب نسائية', 'image': 'Assets/Images/Backpak.jpg'},
    {'title': 'شباشب رجالي', 'image': 'Assets/Images/Shahata.jpg'},
    {'title': 'أحذية أطفال', 'image': 'Assets/Images/Backpak.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < categories.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: PageView.builder(
        controller: _pageController,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];
          return GestureDetector(
            onTap: () {
              if (widget.onCategoryTap != null) {
                widget.onCategoryTap!(item['title']!);
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(item['image']!),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  item['title']!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
