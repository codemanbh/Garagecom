import 'package:flutter/material.dart';
import '../managers/CategoryManager.dart';
import '../models/Category.dart';

Future<void> showCategoriesDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  // Fetch categories before showing dialog
  await CategoryManager.fetchCategories();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            title: Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 400),
              child: CategoryManager.isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Loading categories...', 
                          style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : CategoryManager.categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 48,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No categories found',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: CategoryManager.categories.map((category) {
                          final isSelected = CategoryManager.selectedCategoryId == category.id;
                          
                          return FilterChip(
                            label: Text(category.title),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (isSelected) {
                                  CategoryManager.selectedCategoryId = null;
                                } else {
                                  CategoryManager.selectedCategoryId = category.id;
                                }
                              });
                            },
                            selectedColor: colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: colorScheme.primary,
                            backgroundColor: colorScheme.surface,
                            side: BorderSide(
                              color: isSelected 
                                  ? colorScheme.primary 
                                  : colorScheme.primary.withOpacity(0.3),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            labelStyle: TextStyle(
                              color: isSelected 
                                  ? colorScheme.primary 
                                  : colorScheme.onSurface,
                              fontWeight: isSelected 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
            actionsPadding: const EdgeInsets.all(16),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}