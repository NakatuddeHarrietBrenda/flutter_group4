import 'package:flutter/material.dart';

import '../services/product_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() =>
      _ProductScreenState();
}

class _ProductScreenState
    extends State<ProductScreen> {

  // List to store products
  List products = [];

  // Loading state
  bool isLoading = false;

  // Error message
  String errorMessage = '';

  // Current page
  int currentPage = 1;

  // Last page from API
  int lastPage = 1;

  // Service object
  final ProductService productService =
      ProductService();

  @override
  void initState() {
    super.initState();

    fetchProducts();
  }

  // Fetch products function
  Future<void> fetchProducts() async {

    setState(() {
      isLoading = true;
    });

    try {

      final data =
          await productService.fetchProducts(
        page: currentPage,
      );

      setState(() {

        // Add products to list
        products.addAll(data['data']);

        // Get last page
        lastPage =
            data['meta']['last_page'];

        isLoading = false;
      });

    } catch (e) {

      setState(() {

        errorMessage = e.toString();

        isLoading = false;
      });
    }
  }

  // Load next page
  Future<void> loadMore() async {

    if (currentPage < lastPage) {

      currentPage++;

      await fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'NutriBlend Products',
        ),
      ),

      body: Column(
        children: [

          // Error message
          if (errorMessage.isNotEmpty)

            Padding(
              padding:
                  const EdgeInsets.all(8),

              child: Text(
                errorMessage,
              ),
            ),

          // Product list
          Expanded(

            child: products.isEmpty &&
                    isLoading

                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )

                : ListView.builder(

                    itemCount: products.length,

                    itemBuilder:
                        (context, index) {

                      final product =
                          products[index];

                      return ListTile(

                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(
                            product['main_image'],
                          ),
                        ),

                        title: Text(
                          product['name'],
                        ),

                        subtitle: Text(
                          product[
                              'formatted_price'],
                        ),
                      );
                    },
                  ),
          ),

          // Load more button
          Padding(
            padding:
                const EdgeInsets.all(16),

            child: ElevatedButton(

              onPressed:
                  currentPage == lastPage ||
                          isLoading
                      ? null
                      : loadMore,

              child: isLoading

                  ? const SizedBox(
                      height: 20,
                      width: 20,

                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )

                  : Text(
                      currentPage == lastPage
                          ? 'No More Products'
                          : 'Load More',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}