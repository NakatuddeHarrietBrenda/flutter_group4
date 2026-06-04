import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    final notifications = provider.notifications;

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
          'Notifications',
          style: TextStyle(
            color: Color(0xFFF5F5F0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
        actions: [
          if (notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: const Text(
                'Read All',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 22),
              tooltip: 'Clear All',
              onPressed: () => _confirmClearAll(context, provider),
            ),
          ]
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _buildNotificationCard(context, provider, item);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF161616),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.12), width: 1.5),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              size: 54,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All caught up!',
            style: TextStyle(
              color: Color(0xFFF5F5F0),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair Display',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your system alerts and updates will show up here.',
            style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationProvider provider,
    NotificationItem item,
  ) {
    // Styling depending on read state
    final Color cardColor = item.isRead ? const Color(0xFF161616) : const Color(0xFF1E1E1E);
    final Color borderColor = item.isRead
        ? Colors.white.withOpacity(0.04)
        : const Color(0xFFD4AF37).withOpacity(0.25);

    IconData icon;
    Color iconColor;
    switch (item.type) {
      case 'success':
        icon = Icons.check_circle_outline_rounded;
        iconColor = const Color(0xFFD4AF37);
        break;
      case 'promo':
        icon = Icons.local_offer_outlined;
        iconColor = Colors.purpleAccent;
        break;
      case 'info':
      default:
        icon = Icons.info_outline_rounded;
        iconColor = Colors.blueAccent;
        break;
    }

    return GestureDetector(
      onTap: () => provider.markAsRead(item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: item.isRead
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Icon with background circle
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.08),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: const Color(0xFFF5F5F0),
                            fontSize: 14,
                            fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ),
                      // Time representation
                      Text(
                        _formatTime(item.timestamp),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      height: 1.35,
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

  void _confirmClearAll(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Clear all notifications?',
          style: TextStyle(color: Colors.white, fontFamily: 'Playfair Display'),
        ),
        content: const Text(
          'This action cannot be undone. All notification logs will be cleared.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFFD4AF37))),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('CLEAR ALL', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              provider.clearAll();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inDays < 1) {
      return '${duration.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
