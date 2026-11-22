import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trek_bikes_app/bike.dart';
import 'package:trek_bikes_app/bike_repository.dart';
import 'package:trek_bikes_app/category.dart';
import 'package:trek_bikes_app/category_repository.dart';
import 'package:trek_bikes_app/session_helper.dart';
import 'package:trek_bikes_app/sub_category.dart';
import 'package:trek_bikes_app/sub_category_repository.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> _categories = [];
  List<SubCategory> _subCategories = [];
  List<Bike> _bikes = [];
  int? _categoryId;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadSessionData(),
      _loadCategories(),
      _loadSubCategories(),
      _loadBikes(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSessionData() async {
    String? eml = await SessionHelper.email;
    if (!mounted) return;
    setState(() => _email = eml);
  }

  Future<void> _loadCategories() async {
    try {
      var data = await CategoryRepository.getCategories();
      if (!mounted) return;
      setState(() => _categories = data);
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadSubCategories() async {
    try {
      var data = _categoryId != null
          ? await SubCategoryRepository.getSubCategoriesByCategory(_categoryId!)
          : await SubCategoryRepository.getSubCategories();
      if (!mounted) return;
      setState(() => _subCategories = data);
    } catch (ex) {
      debugPrint('Error loading subcategories: $ex');
    }
  }

  Future<void> _loadBikes() async {
    try {
      var data = await BikeRepository.getBikes();
      if (!mounted) return;
      setState(() => _bikes = data);
    } catch (e) {
      debugPrint('Error loading bikes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String baseUrl = dotenv.env['API_URL'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: _categories.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(p.name),
                    avatar: Image.network(
                      '$baseUrl/categories/${p.icon}',
                      width: 24,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, size: 20),
                    ),
                    selected: _categoryId == p.id,
                    onSelected: (val) async {
                      setState(() {
                        _categoryId = val ? p.id : null;
                      });
                      await _loadSubCategories();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_subCategories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8.0,
                      children: _subCategories.map((p) {
                        return FilterChip(
                          label: Text(p.name),
                          onSelected: (val) {},
                        );
                      }).toList(),
                    ),
                  ),
                Expanded(
                  child: _bikes.isEmpty
                      ? const Center(child: Text('Không có xe nào'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _bikes.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            Bike item = _bikes[index];
                            return Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        '$baseUrl/bikes/${item.imageUrl}',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.directions_bike, size: 48),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text('Price: \$${item.price}'),
                                    ElevatedButton.icon(
                                      onPressed: () => _details(item.id),
                                      label: const Text('Details'),
                                      icon: const Icon(Icons.info_outline, size: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              if (_email == null) ...[
                ElevatedButton.icon(
                  onPressed: _login,
                  label: const Text('Login'),
                  icon: const Icon(Icons.login),
                ),
                ElevatedButton.icon(
                  onPressed: _register,
                  label: const Text('Register'),
                  icon: const Icon(Icons.add),
                ),
              ] else ...[
                UserAccountsDrawerHeader(
                  accountName: const Text('User'),
                  accountEmail: Text(_email!),
                ),
                ElevatedButton.icon(
                  onPressed: _profile,
                  label: const Text('Profile'),
                  icon: const Icon(Icons.person),
                ),
                ElevatedButton.icon(
                  onPressed: _logout,
                  label: const Text('Logout'),
                  icon: const Icon(Icons.logout),
                ),
                ElevatedButton.icon(
                  onPressed: _showCart,
                  label: const Text('Cart'),
                  icon: const Icon(Icons.shopping_bag),
                ),
                ElevatedButton.icon(
                  onPressed: _showOrder,
                  label: const Text('Order'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showOrder() async {
    await Navigator.pushNamed(context, '/order');
  }

  void _showCart() async {
    await Navigator.pushNamed(context, '/cart');
  }

  void _login() async {
    Navigator.pop(context);
    var result = await Navigator.pushNamed(context, '/login');
    if (result == true) {
      _loadSessionData();
    }
  }

  void _details(int id) {
    Navigator.pushNamed(context, '/details', arguments: id);
  }

  void _logout() async {
    await SessionHelper.delete();
    if (!mounted) return;
    setState(() {
      _email = null;
    });
    Navigator.pop(context);
  }

  void _profile() async {}

  void _register() async {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/register');
  }
}
