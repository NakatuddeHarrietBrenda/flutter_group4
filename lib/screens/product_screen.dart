import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/product_service.dart';
import '../models/product.model.dart';
import 'product_detail.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // List to store products
  List<Product> products = [];
  
  // Loading state
  bool isLoading = false;
  bool isFirstLoad = true;
  
  // Error message
  String errorMessage = '';
  
  // Current page
  int currentPage = 1;
  
  // Last page from API
  int lastPage = 1;
  
  // Service object
  final ProductService productService = ProductService();
  
  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    
    // Add listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch products function
  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      if (products.isEmpty) {
        isFirstLoad = true;
      }
    });

    try {
      final data = await productService.fetchProducts(
        page: currentPage,
      );

      setState(() {
        // Convert JSON to Product objects
        final List<Product> newProducts = (data['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
        
        products.addAll(newProducts);
        lastPage = data['meta']['last_page'];
        isLoading = false;
        isFirstLoad = false;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        isFirstLoad = false;
      });
    }
  }

  // Load next page
  Future<void> loadMore() async {
    if (currentPage < lastPage && !isLoading) {
      currentPage++;
      await fetchProducts();
    }
  }

  // Refresh products
  Future<void> refreshProducts() async {
    setState(() {
      products.clear();
      currentPage = 1;
      lastPage = 1;
    });
    await fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NutriBlend Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // Navigate to cart
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Error message
          if (errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  TextButton(
                    onPressed: refreshProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          
          // Product list with Shimmer effect
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshProducts,
              child: products.isEmpty && isFirstLoad
                  ? _buildShimmerGrid()
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.length + (isLoading ? 2 : 0),
                      itemBuilder: (context, index) {
                        // Show loading skeleton at the end
                        if (index >= products.length && isLoading) {
                          return _buildProductShimmer();
                        }
                        
                        final product = products[index];
                        return _buildProductCard(product);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer grid effect for initial load
  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6, // Show 6 shimmer items initially
      itemBuilder: (context, index) => _buildProductShimmer(),
    );
  }

  // Single product card with shimmer effect
  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: Image.network(
                      product.mainImage,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  // Stock badge
                  if (!product.inStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Product Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand
                  Text(
                    product.brand.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Price
                  Text(
                    product.formattedPrice,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Stock indicator
                  if (product.inStock && product.stockQuantity <= 5)
                    Text(
                      'Only ${product.stockQuantity} left',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer effect skeleton loader
  Widget _buildProductShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.white,
            ),
            
            // Content placeholder
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand placeholder
                  Container(
                    width: 60,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  
                  // Title placeholder (2 lines)
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  
                  // Price placeholder
                  Container(
                    width: 80,
                    height: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  
                  // Stock placeholder
                  Container(
                    width: 90,
                    height: 10,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}