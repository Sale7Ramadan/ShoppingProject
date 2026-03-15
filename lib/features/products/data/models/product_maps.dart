import 'package:flutter/material.dart';

final List<String> categories = [
  'نسائي حقائب',
  'نسائي أحذية',
  'رجالي أحذية',
  'رجالي صنادل',
  'نسائي صنادل',
  'أطفال بيبي',
  'أطفال محير',
];

final Map<String, Color> colorsMap = {
  'أحمر': Colors.red,
  'أخضر': Colors.green,
  'أبيض': Colors.white,
  'أصفر': Colors.yellow,
  'أسود': Colors.black,
  'أزرق': Colors.blue,
};

final Map<String, List<int>> sizeRanges = {
  'رجالي أحذية': [40, 45],
  'رجالي صنادل': [40, 45],
  'نسائي أحذية': [36, 41],
  'نسائي صنادل': [36, 41],
  'أطفال محير': [31, 36],
  'أطفال بيبي': [21, 25],
};

List<int> generateSizes(String category) {
  if (!sizeRanges.containsKey(category)) return [];
  final range = sizeRanges[category]!;
  int start = range[0];
  int end = range[1];
  return [for (var i = start; i <= end; i++) i];
}

final List<String> categoriesHor = [
  'الجديدة',
  'الأكثر مبيعا',
  'العروض',
  'رجالي',
  'نسائي',
  'أطفال',
];

List<String> categoriesWithoutSizes = ['نسائي حقائب'];

final Map<String, GlobalKey> itemImageKeys = {};
final GlobalKey cartIconKey = GlobalKey();
