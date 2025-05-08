import 'package:flutter/material.dart';
import 'package:garagecom/managers/PostsManager.dart';
import '../managers/CategoryManager.dart';
import '../models/Category.dart';

// This function displays a dialog that allows the user to select a category.
Future<void> showCategoriesDialog(
    BuildContext context, String selectionType) async {
  final theme = Theme.of(context); // Get the current theme
  final colorScheme = theme.colorScheme; // Get the color scheme from the theme

  // Fetch the categories before showing the dialog
  await CategoryManager.fetchCategories();

  _removeCategory(int categoryIdToBeRemoved) {
    CategoryManager.selectedCategories.remove(categoryIdToBeRemoved);
  }

  _addCategory(int newCategoryId) {
    if (selectionType == 'filter') {
      CategoryManager.selectedCategories.add(newCategoryId);
    } else if (selectionType == 'create') {
      _removeCategory(newCategoryId);
      CategoryManager.selectedCategoryId = newCategoryId;

      CategoryManager.selectedCategories.add(newCategoryId);
    }
  }

  bool _isSelected(int categoryId) {
    if (selectionType == 'filter') {
      return CategoryManager.selectedCategories.contains(categoryId);
    } else {
      // selectionType == 'create'
      return CategoryManager.selectedCategoryId == categoryId;
    }
  }

  // Show the dialog
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        // Allows the dialog to rebuild when state changes (e.g., selecting a chip)
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Rounded corners
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
              width: double.maxFinite, // Makes the dialog take full width
              constraints: const BoxConstraints(maxHeight: 400), // Max height
              child: CategoryManager.isLoading
                  ? Center(
                      // Show loading spinner while categories are loading
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Loading categories...',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : CategoryManager.categories.isEmpty
                      ? Center(
                          // Show message if no categories are found
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 48,
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No categories found',
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          // Display the list of categories as FilterChips
                          child: Wrap(
                            spacing: 8.0, // Space between chips horizontally
                            runSpacing: 8.0, // Space between chips vertically
                            children: CategoryManager.categories
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              Category category = entry.value;
                              final isSelected = _isSelected(category.id);

                              return FilterChip(
                                label: Text(category.title),
                                selected: isSelected,
                                onSelected: (bool selected) {
                                  // Update the selected category when tapped
                                  setState(() {
                                    if (_isSelected(category.id)) {
                                      // Deselect category

                                      _removeCategory(category.id);
                                    } else {
                                      // Select category
                                      _addCategory(category.id);
                                    }
                                  });
                                },
                                selectedColor:
                                    colorScheme.primary.withOpacity(0.2),
                                checkmarkColor: colorScheme.primary,
                                backgroundColor: colorScheme.surface,
                                side: BorderSide(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.primary.withOpacity(0.3),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
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
              // Cancel button: simply closes the dialog
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              // Apply button: also closes the dialog (selection is already handled above)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(100), // Fully rounded button
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
