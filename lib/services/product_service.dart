import '../models/product.model.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  // Fetch paginated products and metadata
  Future<Map<String, dynamic>> fetchProducts({int page = 1}) async {
    final response = await _apiClient.get('/api/v1/products?page=$page');
    
    // Parse the lists
    final List<dynamic> data = response['data'] ?? [];
    final List<Product> products = data.map((json) => Product.fromJson(json)).toList();
    
    // Parse pagination metadata
    final int currentPage = response['meta']?['current_page'] ?? 1;
    final int lastPage = response['meta']?['last_page'] ?? 1;
    final int totalProducts = response['meta']?['total'] ?? 0;
    
    return {
      'products': products,
      'currentPage': currentPage,
      'lastPage': lastPage,
      'total': totalProducts,
    };
  }

  // Submit order (POST /api/v1/orders)
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData, String token) async {
    // Week 5 - Making a POST Request with Bearer Token Authorization
    final response = await _apiClient.post('/api/v1/orders', orderData, token: token);
    return response;
  }

  // Fetch Regions (GET /api/v1/regions)
  Future<List<dynamic>> fetchRegions() async {
    final response = await _apiClient.get('/api/v1/regions');
    return response['data'] ?? [];
  }

  // Fetch Towns cascading under a Region (GET /api/v1/regions/{regionId}/towns)
  Future<List<dynamic>> fetchTowns(int regionId) async {
    final response = await _apiClient.get('/api/v1/regions/$regionId/towns');
    return response['data'] ?? [];
  }
}