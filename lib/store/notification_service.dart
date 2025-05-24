import 'package:flutter/foundation.dart';
import 'package:zenify_chat/store/mock_store.dart';

/// 📬 Business logic for computing total unread room notifications
class NotificationService {
  final MockStoreService store;
  final ValueNotifier<int> unreadCount = ValueNotifier(0);

  NotificationService({required this.store}) {
    // Subscribe to room changes and recompute
    store.rooms.addListener(_updateUnreadCount);
    _updateUnreadCount(); // Initial calculation
  }

  void _updateUnreadCount() {
    final count = store.rooms.value
        .where((room) => room.tileDetails.notificationCount > 0)
        .length;
    unreadCount.value = count;
  }

  void dispose() {
    store.rooms.removeListener(_updateUnreadCount);
    unreadCount.dispose();
  }
}
