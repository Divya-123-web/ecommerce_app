import 'package:ecommerce_app/core/app_colors.dart';
import 'package:ecommerce_app/core/formatters.dart';
import 'package:ecommerce_app/presentation/product_provider.dart';
import 'package:ecommerce_app/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../providers/product_provider.dart';
import '../presentation/primary_button.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late SortOption _sort;
  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductProvider>();
    _sort = provider.sort;
    _range = provider.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort & filter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Text('Sort by',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SortOption.values
                  .map(
                    (o) => ChoiceChip(
                      label: Text(o.label),
                      selected: _sort == o,
                      showCheckmark: false,
                      selectedColor: AppColors.primaryLight,
                      onSelected: (_) => setState(() => _sort = o),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price range',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '${Formatters.price(_range.start)} - ${Formatters.price(_range.end)}',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            RangeSlider(
              values: _range,
              min: provider.minPrice,
              max: provider.maxPrice,
              divisions: 20,
              activeColor: AppColors.primary,
              labels: RangeLabels(
                Formatters.price(_range.start),
                Formatters.price(_range.end),
              ),
              onChanged: (v) => setState(() => _range = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      provider.applyFilters(
                        SortOption.relevance,
                        RangeValues(provider.minPrice, provider.maxPrice),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Apply',
                    onPressed: () {
                      provider.applyFilters(_sort, _range);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}