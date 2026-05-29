import 'product.model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  String get formattedTotalPrice {
    // Format UGX currency cleanly
    final total = totalPrice.toInt();
    final buffer = StringBuffer();
    final totalStr = total.toString();
    
    int count = 0;
    for (int i = totalStr.length - 1; i >= 0; i--) {
      buffer.write(totalStr[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    
    final formatted = buffer.toString().split('').reversed.join('');
    return 'UGX $formatted';
  }
}
