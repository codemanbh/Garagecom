import 'package:garagecom/helpers/apiHelper.dart';
import '../models/Category.dart';

class CategoryManager {
  static List<Category> categories = [];
  static int? selectedCategoryId;
  static bool isLoading = false;
  static List<int> selectedCategories = [];

  static Future<bool> fetchCategories() async {
    isLoading = true;

    try {
      // Make API call to get categories
      final response = await ApiHelper.get('api/Posts/GetPostCategories', {});

      // Check if successful
      if (response['succeeded'] == true &&
          response['parameters'] != null &&
          response['parameters']['PostCategories'] != null) {
        // Clear existing categories
        categories.clear();

        // Parse categories from API response
        List<dynamic> categoriesData = response['parameters']['PostCategories'];

        for (var categoryData in categoriesData) {
          categories.add(Category(
            id: categoryData['postCategoryID'],
            title: categoryData['title'],
          ));
        }

        print('Loaded ${categories.length} categories from API');
        // selectedCategories =
        //     List.from(categoriesData.map<bool>((x) => false).toList());

        isLoading = false;

        return true;
      } else {
        print(
            'Failed to load categories: ${response['message'] ?? 'Unknown error'}');
        isLoading = false;
        return false;
      }
    } catch (e) {
      print('Error loading categories: $e');
      isLoading = false;
      return false;
    }
  }

  // Get the selected category name
  static String? getSelectedCategoryName() {
    if (selectedCategoryId == null) return null;

    for (var category in categories) {
      if (category.id == selectedCategoryId) {
        return category.title;
      }
    }

    return null;
  }
}
