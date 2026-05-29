class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Category',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Brand {
  final int id;
  final String name;

  Brand({
    required this.id,
    required this.name,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Generic',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Product {
  final int id;
  final String name;
  final String sku;
  final double price;
  final String formattedPrice;
  final double wholesalePrice;
  final int stockQuantity;
  final bool inStock;
  final String mainImage;
  final Category category;
  final Brand brand;

  // Premium details built-in (Top, Heart, Base Notes) based on name or ID to look stunning
  final String topNotes;
  final String heartNotes;
  final String baseNotes;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.formattedPrice,
    required this.wholesalePrice,
    required this.stockQuantity,
    required this.inStock,
    required this.mainImage,
    required this.category,
    required this.brand,
    required this.topNotes,
    required this.heartNotes,
    required this.baseNotes,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final String pName = json['name'] ?? 'Luxury Perfume';
    
    // Auto-generate premium details based on perfume characteristics
    String top = 'Bergamot, Mandarin, Pear';
    String heart = 'Jasmine, Orange Blossom, Rose';
    String base = 'Vanilla, Patchouli, Amber, Musk';
    String desc = 'An exquisite formulation designed to captivate and express ultimate luxury. Formulated with carefully handpicked natural elements and essences.';

    if (pName.toLowerCase().contains('rouge') || pName.toLowerCase().contains('red')) {
      top = 'Saffron, Jasmine, Red Currant';
      heart = 'Amberwood, Ambergris, Red Rose';
      base = 'Fir Resin, Cedar, Woody Amber';
      desc = 'A passionate blend of deep red floral essences and rich woody base elements. Velvet Rouge embodies high status, intense presence, and timeless romance.';
    } else if (pName.toLowerCase().contains('oud') || pName.toLowerCase().contains('arabic')) {
      top = 'Agarwood, Cinnamon, Nutmeg';
      heart = 'Sandalwood, Jasmine, Patchouli';
      base = 'Amber, Guaiac Wood, Vanilla, Musk';
      desc = 'A traditional Arabic Oud of magnificent depth. Featuring warm spices, sensual woods, and a legendary trail of smoked agarwood and vanilla sweetness.';
    } else if (pName.toLowerCase().contains('blue') || pName.toLowerCase().contains('aqua') || pName.toLowerCase().contains('sport')) {
      top = 'Grapefruit, Lemon, Mint, Pink Pepper';
      heart = 'Ginger, Nutmeg, Jasmine, Melon';
      base = 'Incense, Vetiver, Cedar, Sandalwood';
      desc = 'Crisp, refreshing, and clean. Inspired by Mediterranean breezes, combining bright citruses with a magnetic smoky incense and vetiver dry-down.';
    } else if (pName.toLowerCase().contains('black') || pName.toLowerCase().contains('night') || pName.toLowerCase().contains('noir')) {
      top = 'Black Pepper, Cardamom, Lavender';
      heart = 'Leather, Iris, Coconut';
      base = 'Dark Chocolate, Tonka Bean, Sandalwood';
      desc = 'An elegant evening fragrance of dark, mysterious charm. Blends rich spices with luxurious leather and dark chocolate for a rich, intimate projection.';
    }

    return Product(
      id: json['id'] ?? 0,
      name: pName,
      sku: json['sku'] ?? 'NBH-GENERIC',
      price: (json['price'] ?? 0.0).toDouble(),
      formattedPrice: json['formatted_price'] ?? 'UGX ${json['price'] ?? 0}',
      wholesalePrice: (json['wholesale_price'] ?? 0.0).toDouble(),
      stockQuantity: json['stock_quantity'] ?? 0,
      inStock: json['in_stock'] ?? (json['stock_quantity'] ?? 0) > 0,
      mainImage: json['main_image'] ?? 'https://images.unsplash.com/photo-1547887537-6158d64c35b3?w=500', // backup premium image
      category: json['category'] != null 
          ? Category.fromJson(json['category']) 
          : Category(id: 0, name: 'General'),
      brand: json['brand'] != null 
          ? Brand.fromJson(json['brand']) 
          : Brand(id: 0, name: 'Generic'),
      topNotes: top,
      heartNotes: heart,
      baseNotes: base,
      description: desc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'formatted_price': formattedPrice,
      'wholesale_price': wholesalePrice,
      'stock_quantity': stockQuantity,
      'in_stock': inStock,
      'main_image': mainImage,
      'category': category.toJson(),
      'brand': brand.toJson(),
    };
  }
}
