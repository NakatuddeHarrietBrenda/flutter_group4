import 'package:flutter/material.dart';
import '../models/product.model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadMoreRunning = false;
  String _errorMessage = '';
  
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalProducts = 0;

  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadMoreRunning => _isLoadMoreRunning;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalProducts => _totalProducts;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Real-time calculated filtered products (Search query + Selected category)
  List<Product> get filteredProducts {
    return _products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            product.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            product.brand.name.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'All' || 
                              product.category.name.toLowerCase().trim() == _selectedCategory.toLowerCase().trim();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Get all unique categories dynamically from loaded products
  List<String> get categories {
    final Set<String> uniqueCats = {'All'};
    for (var p in _products) {
      if (p.category.name.isNotEmpty) {
        // Standardize category casing
        final name = p.category.name.trim();
        uniqueCats.add(name);
      }
    }
    return uniqueCats.toList();
  }

  // Setters with notifyListeners for live UI updates
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Reset filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    notifyListeners();
  }

  // Initial Fetch (Page 1)
  Future<void> fetchInitialProducts() async {
    _isLoading = true;
    _errorMessage = '';
    _currentPage = 1;
    // Clear list to show shimmer or blank slate
    _products = [];
    notifyListeners();

    try {
      final result = await _productService.fetchProducts(page: 1);
      _products = result['products'];
      _currentPage = result['currentPage'];
      _lastPage = result['lastPage'];
      _totalProducts = result['total'];
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  // Load More (Pagination - Next Pages)
  Future<void> loadMoreProducts() async {
    if (_currentPage >= _lastPage || _isLoadMoreRunning || _isLoading) return;

    _isLoadMoreRunning = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _productService.fetchProducts(page: nextPage);
      
      _products.addAll(result['products']);
      _currentPage = result['currentPage'];
      _lastPage = result['lastPage'];
      _totalProducts = result['total'];
      
      _isLoadMoreRunning = false;
    } catch (e) {
      // Don't override general loading error, show transient message or toast in UI
      _errorMessage = 'Could not load more products: ${e.toString()}';
      _isLoadMoreRunning = false;
    }
    notifyListeners();
  }

  // Error recovery helper
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
