import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/product_service.dart';
import '../widgets/shimmer_loader.dart';
import '../providers/notification_provider.dart';
import 'checkout_success.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Region and Town states
  List<dynamic> _regions = [];
  List<dynamic> _towns = [];
  bool _isLoadingRegions = false;
  bool _isLoadingTowns = false;
  String? _regionsError;
  String? _townsError;

  int? _selectedRegionId;
  int? _selectedTownId;
  String? _selectedDeliveryMethod = 'Standard Delivery';

  bool _isSubmitting = false;
  String? _submissionError;

  final List<String> _deliveryMethods = [
    'Standard Delivery',
    'Express Delivery',
    'Store Pickup',
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialRegions();
    // Prefill name if user is logged in
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLoggedIn) {
      _nameController.text = auth.name ?? '';
      _phoneController.text = auth.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Fetch all regions on init (GET /api/v1/regions)
  Future<void> _fetchInitialRegions() async {
    setState(() {
      _isLoadingRegions = true;
      _regionsError = null;
    });

    try {
      final regionsList = await _productService.fetchRegions();
      setState(() {
        _regions = regionsList;
        _isLoadingRegions = false;
      });
    } catch (e) {
      setState(() {
        _regionsError = 'Failed to load regions. Tap to retry.';
        _isLoadingRegions = false;
      });
    }
  }

  // Fetch towns when region is chosen (GET /api/v1/regions/{id}/towns)
  Future<void> _fetchTownsForRegion(int regionId) async {
    setState(() {
      _isLoadingTowns = true;
      _towns = [];
      _selectedTownId = null;
      _townsError = null;
    });

    try {
      final townsList = await _productService.fetchTowns(regionId);
      setState(() {
        _towns = townsList;
        _isLoadingTowns = false;
      });
    } catch (e) {
      setState(() {
        _townsError = 'Failed to load towns for this region.';
        _isLoadingTowns = false;
      });
    }
  }

  // Place Order Action (POST /api/v1/orders)
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRegionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery region.')),
      );
      return;
    }

    if (_selectedTownId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery town.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final List<Map<String, dynamic>> orderItems = cartProvider.items.values.map((item) {
      return {
        'product_id': item.product.id,
        'quantity': item.quantity,
      };
    }).toList();

    final orderPayload = {
      'items': orderItems,
      'delivery_method': _selectedDeliveryMethod,
      'delivery_region_id': _selectedRegionId,
      'delivery_town_id': _selectedTownId,
      'delivery_address': _addressController.text.trim(),
      // Adding extra information for visual receipt
      'customer_name': _nameController.text.trim(),
      'customer_phone': _phoneController.text.trim(),
    };

    try {
      final token = authProvider.token;
      if (token == null) {
        throw Exception('Session token expired. Please log in again.');
      }

      await _productService.createOrder(orderPayload, token);

      if (mounted) {
        // Trigger order placement success notification
        Provider.of<NotificationProvider>(context, listen: false).addNotification(
          title: 'Simulated Order Placed',
          message: 'Your NutriBlend order for ${cartProvider.totalItemCount} item(s) has been successfully dispatched to ${_addressController.text.trim()}.',
          type: 'success',
        );
        final total = cartProvider.totalAmount;
        final name = _nameController.text.trim();

        // Clear the cart on successful completion
        cartProvider.clearCart();

        // Go to checkout success screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CheckoutSuccessScreen(
              orderTotal: total,
              customerName: name,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _submissionError = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Color(0xFFF5F5F0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Information',
                  style: TextStyle(
                    color: Color(0xFFF5F5F0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please fill in your correct dispatch details.',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
                const SizedBox(height: 24),

                // Name Input
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                // Phone Input
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your phone number' : null,
                ),
                const SizedBox(height: 16),

                // Cascading Regions Dropdown or Shimmer
                if (_isLoadingRegions)
                  _buildShimmerLoaderField(label: 'Loading Regions...')
                else if (_regionsError != null)
                  _buildErrorField(message: _regionsError!, onRetry: _fetchInitialRegions)
                else
                  _buildRegionDropdown(),
                const SizedBox(height: 16),

                // Cascading Towns Dropdown or Shimmer
                if (_isLoadingTowns)
                  _buildShimmerLoaderField(label: 'Loading Towns...')
                else if (_townsError != null)
                  _buildErrorField(message: _townsError!, onRetry: () => _fetchTownsForRegion(_selectedRegionId!))
                else if (_selectedRegionId != null)
                  _buildTownDropdown()
                else
                  _buildDisabledDropdownField(label: 'Select Region First'),
                const SizedBox(height: 16),

                // Delivery Method Dropdown
                _buildDeliveryMethodDropdown(),
                const SizedBox(height: 16),

                // Physical Address Input
                _buildTextField(
                  controller: _addressController,
                  label: 'Physical Delivery Address',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your specific physical address' : null,
                ),
                const SizedBox(height: 24),

                // Invoice Summary card
                _buildOrderSummaryCard(cartProvider),
                const SizedBox(height: 20),

                // Submission Error
                if (_submissionError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _submissionError!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      disabledBackgroundColor: const Color(0xFFD4AF37).withOpacity(0.4),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'PLACE SIMULATED ORDER',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dropdown builders
  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedRegionId,
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: _getInputDecoration('Region', Icons.map_outlined),
      items: _regions.map<DropdownMenuItem<int>>((region) {
        return DropdownMenuItem<int>(
          value: region['id'],
          child: Text(region['name'] ?? ''),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedRegionId = val;
          });
          _fetchTownsForRegion(val);
        }
      },
      validator: (val) => val == null ? 'Please select a region' : null,
    );
  }

  Widget _buildTownDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedTownId,
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: _getInputDecoration('Town', Icons.home_work_outlined),
      items: _towns.map<DropdownMenuItem<int>>((town) {
        return DropdownMenuItem<int>(
          value: town['id'],
          child: Text(town['name'] ?? ''),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedTownId = val;
        });
      },
      validator: (val) => val == null ? 'Please select a town' : null,
    );
  }

  Widget _buildDeliveryMethodDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDeliveryMethod,
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: _getInputDecoration('Delivery Method', Icons.local_shipping_outlined),
      items: _deliveryMethods.map<DropdownMenuItem<String>>((method) {
        return DropdownMenuItem<String>(
          value: method,
          child: Text(method),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedDeliveryMethod = val;
        });
      },
    );
  }

  // Loaders & Shimmer
  Widget _buildShimmerLoaderField({required String label}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const ShimmerLoader(width: 20, height: 20, borderRadius: 10),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
          const Spacer(),
          const ShimmerLoader(width: 50, height: 16, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _buildDisabledDropdownField({required String label}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.06)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.home_work_outlined, color: const Color(0xFFD4AF37).withOpacity(0.2), size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13)),
          const Spacer(),
          Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.2)),
        ],
      ),
    );
  }

  Widget _buildErrorField({required String message, required VoidCallback onRetry}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37), size: 18),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.12)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              color: Color(0xFFF5F5F0),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair Display',
            ),
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Items TotalCount', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              Text('${cartProvider.totalItemCount} items', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount Due', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              Text(
                cartProvider.formattedTotalAmount,
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: _getInputDecoration(label, icon),
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
    );
  }
}
