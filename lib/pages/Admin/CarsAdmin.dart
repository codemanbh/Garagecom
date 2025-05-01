import 'package:flutter/material.dart';
import '../../helpers/apiHelper.dart';
import '../../managers/UserService.dart';

class CarsAdmin extends StatefulWidget {
  const CarsAdmin({super.key});

  @override
  State<CarsAdmin> createState() => _CarsAdminState();
}

class _CarsAdminState extends State<CarsAdmin> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  bool _isLoading = false;

  // Data lists
  List<dynamic> brands = [];
  List<dynamic> models = [];
  List<dynamic> parts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
      // Load data for the selected tab
      _loadDataForCurrentTab();
    });
    
    // Initial data load
    _loadDataForCurrentTab();
  }

  Future<void> _loadDataForCurrentTab() async {
    switch (_selectedIndex) {
      case 0:
        _loadBrands();
        break;
      case 1:
        _loadModels();
        break;
      case 2:
        _loadParts();
        break;
    }
  }

  Future<void> _loadBrands() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await UserService.getCarBrands();
      
      if (response['succeeded'] == true && 
          response['parameters'] != null &&
          response['parameters']['Brands'] != null) {
        
        setState(() {
          brands = response['parameters']['Brands'];
          _isLoading = false;
        });
      } else {
        setState(() {
          brands = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load brands: ${response['message'] ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading brands: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiHelper.get('/api/Cars/GetCarModels', {});
      
      if (response['succeeded'] == true && 
          response['parameters'] != null &&
          response['parameters']['CarModels'] != null) {
        
        setState(() {
          models = response['parameters']['CarModels'];
          _isLoading = false;
        });
      } else {
        setState(() {
          models = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load models: ${response['message'] ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading models: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadParts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiHelper.get('/api/Cars/GetParts', {});
      
      if (response['succeeded'] == true && 
          response['parameters'] != null &&
          response['parameters']['Parts'] != null) {
        
        setState(() {
          parts = response['parameters']['Parts'];
          _isLoading = false;
        });
      } else {
        setState(() {
          parts = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load parts: ${response['message'] ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading parts: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteBrand(dynamic brand) async {
    final brandId = brand['brandID'];
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Brand'),
        content: Text('Are you sure you want to delete ${brand['brandName']}? This will also delete all associated models.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // You'll need to implement the API call to delete a brand
      final response = await ApiHelper.post('/api/Cars/DeleteBrand', {
        'brandID': brandId
      });
      
      if (response['succeeded'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Brand "${brand['brandName']}" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBrands();
      } else {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete brand: ${response['message'] ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting brand: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteModel(dynamic model) async {
    final modelId = model['carModelID'];
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Model'),
        content: Text('Are you sure you want to delete ${model['modelName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // You'll need to implement the API call to delete a model
      final response = await ApiHelper.post('/api/Cars/DeleteCarModel', {
        'carModelID': modelId
      });
      
      if (response['succeeded'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Model "${model['modelName']}" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadModels();
      } else {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete model: ${response['message'] ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting model: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePart(dynamic part) async {
    final partId = part['partID'];
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Part'),
        content: Text('Are you sure you want to delete ${part['partName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // You'll need to implement the API call to delete a part
      final response = await ApiHelper.post('/api/Cars/DeletePart', {
        'partID': partId
      });
      
      if (response['succeeded'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Part "${part['partName']}" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadParts();
      } else {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete part: ${response['message'] ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting part: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddBrandDialog() {
    final TextEditingController brandNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Car Brand'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: brandNameController,
            decoration: const InputDecoration(
              labelText: 'Brand Name',
              hintText: 'Enter car brand name (e.g., BMW, Toyota)',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a brand name';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  // API call to add a new brand
                  final response = await ApiHelper.post('/api/Cars/SetBrand', {
                    'brandName': brandNameController.text
                  });
                  
                  if (response['succeeded'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Brand "${brandNameController.text}" added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadBrands();
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add brand: ${response['message'] ?? "Unknown error"}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding brand: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddModelDialog() {
    final TextEditingController modelNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    dynamic selectedBrand;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Car Model'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<dynamic>(
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                  ),
                  value: selectedBrand,
                  items: brands.map((brand) {
                    return DropdownMenuItem<dynamic>(
                      value: brand,
                      child: Text(brand['brandName']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBrand = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a brand';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: modelNameController,
                  decoration: const InputDecoration(
                    labelText: 'Model Name',
                    hintText: 'Enter model name (e.g., Corolla, 3 Series)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a model name';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  
                  setState(() {
                    _isLoading = true;
                  });
                  
                  try {
                    // API call to add a new model
                    final response = await ApiHelper.post('/api/Cars/SetCarModel', {
                      'brandID': selectedBrand['brandID'],
                      'modelName': modelNameController.text
                    });
                    
                    if (response['succeeded'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Model "${modelNameController.text}" added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadModels();
                    } else {
                      this.setState(() {
                        _isLoading = false;
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add model: ${response['message'] ?? "Unknown error"}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    this.setState(() {
                      _isLoading = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding model: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPartDialog() {
    final TextEditingController partNameController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Car Part'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: partNameController,
                decoration: const InputDecoration(
                  labelText: 'Part Name',
                  hintText: 'Enter part name (e.g., Engine Oil, Air Filter)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a part name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Part Description',
                  hintText: 'Enter part description or notes',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  // API call to add a new part
                  final response = await ApiHelper.post('/api/Cars/SetPart', {
                    'partName': partNameController.text,
                    'notes': noteController.text
                  });
                  
                  if (response['succeeded'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Part "${partNameController.text}" added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadParts();
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add part: ${response['message'] ?? "Unknown error"}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding part: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
        title: const Text('Cars Management'),
        actions: [
          IconButton(
            onPressed: _loadDataForCurrentTab,
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
              icon: Icon(Icons.branding_watermark),
              text: "Brands",
            ),
            Tab(
              icon: Icon(Icons.directions_car),
              text: "Models",
            ),
            Tab(
              icon: Icon(Icons.build),
              text: "Parts",
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Brands Tab
                _buildBrandsTab(colorScheme),
                
                // Models Tab
                _buildModelsTab(colorScheme),
                
                // Parts Tab
                _buildPartsTab(colorScheme),
              ],
            ),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
    );
  }

  Widget _buildFloatingActionButton(ColorScheme colorScheme) {
    // Different FAB for each tab
    switch (_selectedIndex) {
      case 0: // Brands tab
        return FloatingActionButton.extended(
          onPressed: _showAddBrandDialog,
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Brand'),
          tooltip: 'Add new brand',
        );
      case 1: // Models tab
        return FloatingActionButton.extended(
          onPressed: brands.isEmpty ? null : _showAddModelDialog,
          backgroundColor: brands.isEmpty ? Colors.grey : colorScheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Model'),
          tooltip: brands.isEmpty ? 'Add brands first' : 'Add new model',
        );
      case 2: // Parts tab
        return FloatingActionButton.extended(
          onPressed: _showAddPartDialog,
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Part'),
          tooltip: 'Add new part',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBrandsTab(ColorScheme colorScheme) {
    if (brands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.branding_watermark,
              size: 64,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Brands Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first car brand using the + button',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: Text(
                brand['brandName'].substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              brand['brandName'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: colorScheme.error,
              ),
              onPressed: () => _deleteBrand(brand),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModelsTab(ColorScheme colorScheme) {
    if (models.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 64,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Models Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            brands.isEmpty
                ? Text(
                    'Add brands first, then add models',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : Text(
                    'Add your first car model using the + button',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondary,
              child: Text(
                model['modelName'].substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              model['modelName'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: model['brand'] != null
                ? Text(
                    'Brand: ${model['brand']['brandName']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: colorScheme.error,
              ),
              onPressed: () => _deleteModel(model),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPartsTab(ColorScheme colorScheme) {
    if (parts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build,
              size: 64,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Parts Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first car part using the + button',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: parts.length,
      itemBuilder: (context, index) {
        final part = parts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: colorScheme.tertiary,
              child: const Icon(
                Icons.build,
                color: Colors.white,
              ),
            ),
            title: Text(
              part['partName'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: part['notes'] != null && part['notes'].isNotEmpty
                ? Text(
                    part['notes'],
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: colorScheme.error,
              ),
              onPressed: () => _deletePart(part),
            ),
          ),
        );
      },
    );
  }
}