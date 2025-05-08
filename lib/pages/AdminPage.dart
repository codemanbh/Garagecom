import 'package:flutter/material.dart';
import '../components/PostCard.dart';
import '../models/Post.dart';
import '../managers/PostsManager.dart';
import '../Pages/Admin/PostsAdmin.dart';
import '../Pages/Admin/carsAdmin.dart';


class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            onPressed: () {
              // Refresh the current tab
              if (_selectedIndex == 0) {
                final postsTab = _tabController.animation!.value == 0 
                    ? PostsAdminTabState.refreshPosts 
                    : null;
                if (postsTab != null) postsTab();
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
          tabs: const [
            Tab(
              icon: Icon(Icons.post_add),
              text: "Posts",
            ),
            Tab(
              icon: Icon(Icons.branding_watermark),
              text: "Cars",
            ),
            Tab(
              icon: Icon(Icons.directions_car),
              text: "Users",
            ),
            
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Posts Tab
          PostsAdminTab(),
          
          // Car Brands Tab
          CarsAdmin(),          
         
        ],
      ),
    );
  }

  
}

