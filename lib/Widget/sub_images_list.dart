import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/Cubit/AddProduct/product_cubit.dart';
import 'package:shopping_app/services/ProductMaps.dart';

class SubImagesList extends StatelessWidget {
  final List<Map<String, dynamic>> existingSubImages;
  final List<File> newSubImages;
  final List<Map<int, int>> newSubImagesSizes;
  final String category;

  const SubImagesList({
    Key? key,
    required this.existingSubImages,
    required this.newSubImages,
    required this.newSubImagesSizes,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductCubit>();

    final existingCount = existingSubImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الصور الفرعية الموجودة
        ...List.generate(existingCount, (index) {
          final imageData = existingSubImages[index];
          final imageUrl = imageData['image'] as String;

          final rawSizes = Map<String, dynamic>.from(
            imageData['sizes_quantities'] ?? {},
          );
          final sizesMap = rawSizes.map(
            (key, value) => MapEntry(int.parse(key), value as int),
          );

          return SubImageItem(
            isExisting: true,
            index: index,
            displayNumber: index + 1,
            imageUrl: imageUrl,
            sizesMap: sizesMap,
            onSizesChanged: (updatedMap) {
              cubit.updateExistingSubImageData(index, updatedMap);
            },
            onRemove: () {
              cubit.removeExistingSubImage(index);
            },
            category: category,
          );
        }),
        // الصور الفرعية الجديدة
        ...List.generate(newSubImages.length, (index) {
          final file = newSubImages[index];
          final sizesMap = newSubImagesSizes[index];

          return SubImageItem(
            isExisting: false,
            index: index,
            displayNumber: existingCount + index + 1,
            file: file,
            sizesMap: sizesMap,
            onSizesChanged: (updatedMap) {
              cubit.updateSubImageData(index, updatedMap);
            },
            onRemove: () {
              cubit.removeSubImage(index);
            },
            category: category,
          );
        }),
      ],
    );
  }
}

class SubImageItem extends StatefulWidget {
  final bool isExisting;
  final int index;
  final int displayNumber;
  final String? imageUrl;
  final File? file;
  final Map<int, int> sizesMap;
  final void Function(Map<int, int>) onSizesChanged;
  final VoidCallback onRemove;
  final String category;

  const SubImageItem({
    Key? key,
    required this.isExisting,
    required this.index,
    required this.displayNumber,
    this.imageUrl,
    this.file,
    required this.sizesMap,
    required this.onSizesChanged,
    required this.onRemove,
    required this.category,
  }) : assert(isExisting ? imageUrl != null : file != null),
       super(key: key);

  @override
  State<SubImageItem> createState() => _SubImageItemState();
}

class _SubImageItemState extends State<SubImageItem> {
  late Map<int, int> localSizes;
  late List<int> availableSizes;
  final Map<int, TextEditingController> _controllers = {};
  late bool isWithoutSizes;

  @override
  void initState() {
    super.initState();
    isWithoutSizes = categoriesWithoutSizes.contains(widget.category);
    localSizes = Map.from(widget.sizesMap);
    availableSizes = generateSizes(widget.category);

    if (!isWithoutSizes) {
      for (var entry in localSizes.entries) {
        _controllers[entry.key] = TextEditingController(
          text: entry.value.toString(),
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant SubImageItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.category != widget.category ||
        oldWidget.sizesMap != widget.sizesMap) {
      setState(() {
        isWithoutSizes = categoriesWithoutSizes.contains(widget.category);
        availableSizes = generateSizes(widget.category);
        localSizes = Map.from(widget.sizesMap);

        for (var entry in localSizes.entries) {
          if (!_controllers.containsKey(entry.key)) {
            _controllers[entry.key] = TextEditingController(
              text: entry.value.toString(),
            );
          } else {}
        }
      });
    }
  }

  void toggleSize(int size) {
    setState(() {
      if (localSizes.containsKey(size)) {
        localSizes.remove(size);
        if (_controllers.containsKey(size)) {
          _controllers[size]!.text = '';
        }
      } else {
        localSizes[size] = 1;
        if (!_controllers.containsKey(size)) {
          _controllers[size] = TextEditingController(text: '1');
        }
      }
    });
    widget.onSizesChanged(localSizes);
  }

  void updateQuantity(int size, String value) {
    final quantity = int.tryParse(value);
    setState(() {
      if (quantity == null) {
        localSizes[size] = 0;
      } else if (quantity <= 0) {
        localSizes.remove(size);
        _controllers[size]?.text = '';
      } else {
        localSizes[size] = quantity;
      }
    });
    widget.onSizesChanged(localSizes);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                widget.isExisting
                    ? Image.network(
                        widget.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        widget.file!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                const SizedBox(width: 12),
                Expanded(child: Text('صورة فرعية رقم ${widget.displayNumber}')),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (isWithoutSizes) ...[
              const Text('الكمية المتوفرة:'),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: localSizes[0]?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'أدخل الكمية',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (val) {
                  final quantity = int.tryParse(val) ?? 0;
                  setState(() {
                    localSizes = {0: quantity};
                  });
                  widget.onSizesChanged(localSizes);
                },
              ),
            ],

            if (!isWithoutSizes) ...[
              const Text('اختر المقاسات:'),
              Wrap(
                spacing: 8,
                children: availableSizes.map((size) {
                  final selected = localSizes.containsKey(size);
                  return ChoiceChip(
                    label: Text('$size'),
                    selected: selected,
                    onSelected: (_) => toggleSize(size),
                    selectedColor: Colors.blue,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              if (localSizes.isNotEmpty) const Text('الكميات لكل مقاس:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: localSizes.entries.map((entry) {
                  return SizedBox(
                    width: 70,
                    child: TextFormField(
                      controller: _controllers[entry.key],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: entry.key.toString(),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (val) {
                        updateQuantity(entry.key, val);
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
