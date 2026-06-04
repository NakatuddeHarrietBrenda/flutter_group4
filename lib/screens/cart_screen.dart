import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import 'checkout_success.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        title: const Text(
          'Shopping Bag',
          style: TextStyle(
            color: Color(0xFFF5F5F0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              onPressed: () {
                _showClearConfirmationDialog(context, cartProvider);
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // Cart Items Scroll
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItemCard(context, item, cartProvider);
                    },
                  ),
                ),
                
                // Invoice Details and CTA
                _buildOrderSummarySection(context, cartProvider),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E1E1E),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFFD4AF37),
              size: 54,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your bag is empty',
            style: TextStyle(
              color: Color(0xFFF5F5F0),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair Display',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore our luxury catalog and discover your signature scent.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, dynamic item, CartProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.08),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Product Thumbnail Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF2E2E2E),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.product.mainImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported_outlined, color: Color(0xFFD4AF37));
                },
              ),
            ),
          ),
          const SizedBox(width: 14),
          
          // Title, Price, Quantities
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF5F5F0),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                Text(
                  item.product.brand.name.toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xFFD4AF37).withOpacity(0.85),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.product.formattedPrice,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity Adjuster Capsule
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Trash Icon to remove entirely
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white24, size: 20),
                onPressed: () {
                  provider.removeItem(item.product.id);
                },
              ),
              
              // Capsule adjustments
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => provider.decrementQuantity(item.product.id),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.remove, color: Color(0xFFD4AF37), size: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          color: Color(0xFFF5F5F0),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => provider.addItem(item.product),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.add, color: Color(0xFFD4AF37), size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(BuildContext context, CartProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.18),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
              ),
              Text(
                provider.formattedTotalAmount,
                style: const TextStyle(color: Color(0xFFF5F5F0), fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping Delivery',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
              ),
              const Text(
                'FREE',
                style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(color: Color(0xFFF5F5F0), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
              ),
              Text(
                provider.formattedTotalAmount,
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Checkout CTA button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                if (!auth.isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1E1E1E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      content: const Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Authentication required. Please log in or sign up to checkout.',
                              style: TextStyle(color: Color(0xFFF5F5F0)),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  Navigator.pushNamed(context, '/login');
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: const Text(
                'PROCEED TO CHECKOUT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context, CartProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Clear Cart?', style: TextStyle(color: Colors.white, fontFamily: 'Playfair Display')),
        content: const Text('Do you want to remove all items from your boutique cart?', style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFFD4AF37))),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('CLEAR ALL', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              provider.clearCart();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
