import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';

// Screens
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'NutriBlend Haven',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F0F0F),
          primaryColor: const Color(0xFFD4AF37),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            secondary: Color(0xFFA37F14),
            background: Color(0xFF0F0F0F),
            surface: Color(0xFF161616),
            error: Colors.redAccent,
          ),
          
          // Premium Luxury Font Typography configuration
          fontFamily: 'Outfit',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Playfair Display', color: Color(0xFFF5F5F0)),
            displayMedium: TextStyle(fontFamily: 'Playfair Display', color: Color(0xFFF5F5F0)),
            headlineLarge: TextStyle(fontFamily: 'Playfair Display', color: Color(0xFFF5F5F0), fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(fontFamily: 'Playfair Display', color: Color(0xFFF5F5F0), fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontFamily: 'Playfair Display', color: Color(0xFFF5F5F0), fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(color: Color(0xFFF5F5F0)),
            bodyMedium: TextStyle(color: Color(0xFFF5F5F0)),
          ),
          
          // Modern bottom sheet style settings
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Color(0xFF1A1A1A),
            elevation: 10,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}