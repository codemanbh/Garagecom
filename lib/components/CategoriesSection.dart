import 'package:flutter/material.dart';
import '../managers/CategoriesManager.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  List<bool> isSelectedList =
      CategoriesManager.categories.map<bool>((c) => false).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 8.0, // Horizontal spacing between buttons
      runSpacing: 8.0, // Vertical spacing between lines
      children: CategoriesManager.categories.asMap().entries.map(
        (c) {
          int index = c.key;
          bool isSelected = isSelectedList[index];

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                c.value.title,
                style: TextStyle(
                  color: isSelected 
                      ? colorScheme.onPrimaryContainer 
                      : colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            backgroundColor: isSelected 
                ? colorScheme.primaryContainer.withOpacity(0.2) 
                : colorScheme.surfaceVariant,
            selectedColor: colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
              side: BorderSide(
                color: isSelected 
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            onSelected: (bool selected) {
              setState(() {
                isSelectedList[index] = selected;
              });
            },
          );
        },
      ).toList(),
    );
  }
}
