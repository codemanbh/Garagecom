import '../models/Category.dart';

class CategoriesManager {
  static List<Category> categories = [
    Category(
        id: 0,
        title: 'Accord',
        description:
            "Honda Accord – a perfect mix of performance, comfort, and style for any drive."),
    Category(
        id: 1,
        title: 'For Sale',
        description:
            "Buy or sell cars easily with great deals and trusted sellers."),
    Category(
        id: 2,
        title: 'Need Help',
        description:
            "Get assistance with car issues, maintenance, or recommendations."),
    Category(
        id: 3,
        title: 'Sport',
        description:
            "Explore high-performance cars built for speed and excitement."),
    Category(
        id: 4,
        title: 'SUV',
        description:
            "Spacious and powerful SUVs for adventure, comfort, and family trips."),
    Category(
        id: 5,
        title: 'Electric',
        description:
            "Discover eco-friendly electric cars with advanced technology."),
    Category(
        id: 6,
        title: 'Classic',
        description:
            "Timeless classic cars with vintage charm and unique appeal."),
    Category(
        id: 7,
        title: 'Luxury',
        description:
            "Premium cars with top-tier comfort, design, and cutting-edge features."),
    Category(
        id: 8,
        title: 'Off-Road',
        description:
            "Rugged vehicles designed for adventure and tough terrains.")
  ];
}
