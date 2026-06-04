import 'package:flutter/material.dart';
import '../main.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type; // 'info', 'success', 'promo'
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    // Add default system greeting notification
    addNotification(
      title: 'Welcome to NutriBlend Haven',
      message: 'Explore our catalog of signature luxury fragrances and boutique options.',
      type: 'info',
    );
  }

  void addNotification({
    required String title,
    required String message,
    required String type,
  }) {
    final newItem = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );
    _notifications.insert(0, newItem);
    notifyListeners();

    // Trigger visual global SnackBar toast
    final state = MyApp.scaffoldMessengerKey.currentState;
    if (state != null) {
      // Choose icon and color based on notification type
      IconData icon;
      Color themeColor;
      switch (type) {
        case 'success':
          icon = Icons.check_circle_outline_rounded;
          themeColor = const Color(0xFFD4AF37);
          break;
        case 'promo':
          icon = Icons.local_offer_outlined;
          themeColor = Colors.purpleAccent;
          break;
        case 'info':
        default:
          icon = Icons.info_outline_rounded;
          themeColor = Colors.blueAccent;
          break;
      }

      state.hideCurrentSnackBar();
      state.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF161616),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: themeColor.withOpacity(0.4), width: 1.2),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColor.withOpacity(0.08),
                ),
                child: Icon(icon, color: themeColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 3),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool updated = false;
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        updated = true;
      }
    }
    if (updated) {
      notifyListeners();
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
