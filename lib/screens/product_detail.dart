import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.model.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        slivers: [
          // Floating Luxury Scollable Header
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: const Color(0xFF161616),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: Image.network(
                      product.mainImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Color(0xFFD4AF37),
                            size: 72,
                          ),
                        );
                      },
                    ),
                  ),
                  // Dark bottom gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                            Colors.black.withOpacity(0.9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Body Details List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & Stock status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                        ),
                        child: Text(
                          product.brand.name.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      
                      // Stock Indicator
                      _buildStockStatusBadge(product),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Color(0xFFF5F5F0),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // SKU & Category Line
                  Row(
                    children: [
                      Text(
                        'Category: ${product.category.name}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'SKU: ${product.sku}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(color: Colors.white10, height: 32),
                  
                  // Pricing
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BOUTIQUE PRICE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(color: Colors.white10, height: 32),
                  
                  // Description
                  const Text(
                    'Fragrance Chronicle',
                    style: TextStyle(
                      color: Color(0xFFF5F5F0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Premium Ingredient / Olfactory Profiler
                  const Text(
                    'Olfactory Notes Profile',
                    style: TextStyle(
                      color: Color(0xFFF5F5F0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  // Top, Heart, Base Notes UI
                  _buildNotesCard(
                    'Top Notes',
                    'The initial opening burst (0 - 15 mins)',
                    product.topNotes,
                    Icons.bubble_chart_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildNotesCard(
                    'Heart Notes',
                    'The core personality body (15 mins - 4 hrs)',
                    product.heartNotes,
                    Icons.favorite_border_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildNotesCard(
                    'Base Notes',
                    'The rich drying warmth trail (4 hrs - 24 hrs)',
                    product.baseNotes,
                    Icons.forest_outlined,
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
      
      // Bottom Buy Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          border: Border(
            top: BorderSide(
              color: const Color(0xFFD4AF37).withOpacity(0.15),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Price Display
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL COST',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              
              // Add to Cart CTA
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: product.inStock
                        ? () {
                            cartProvider.addItem(product);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF1E1E1E),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
                                ),
                                content: Row(
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined, color: Color(0xFFD4AF37)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${product.name} added to cart!',
                                        style: const TextStyle(color: Color(0xFFF5F5F0)),
                                      ),
                                    ),
                                  ],
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      disabledBackgroundColor: Colors.white.withOpacity(0.08),
                    ),
                    child: Text(
                      product.inStock ? 'ADD TO CART' : 'SOLD OUT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 12,
                        color: product.inStock ? Colors.black : Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockStatusBadge(Product product) {
    if (!product.inStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red.withOpacity(0.4)),
        ),
        child: const Text(
          'OUT OF STOCK',
          style: TextStyle(
            color: Colors.red,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (product.stockQuantity <= 5) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF9800).withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.4)),
        ),
        child: Text(
          'ONLY ${product.stockQuantity} LEFT',
          style: const TextStyle(
            color: Color(0xFFFF9800),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.withOpacity(0.4)),
        ),
        child: const Text(
          'IN STOCK',
          style: TextStyle(
            color: Colors.green,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildNotesCard(String title, String subtitle, String notes, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFF5F5F0),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notes,
                  style: TextStyle(
                    color: const Color(0xFFF5F5F0).withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
