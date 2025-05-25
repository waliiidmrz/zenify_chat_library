import 'package:flutter/foundation.dart';
import 'package:zenify_chat/models/chatroom.dart';

/// 🏪 Reactive in-memory store for managing active chat rooms.

class StoreService {
  final ValueNotifier<List<ChatRoom>> rooms = ValueNotifier([]);
  final ValueNotifier<int> unreadRoomCount = ValueNotifier<int>(0);

  /// 🚀 Replaces the current room list with a new set of rooms.

  void setRooms(List<ChatRoom> newRooms) {
    rooms.value = List<ChatRoom>.from(newRooms);
  }

  /// 🔁 Adds a new room or updates an existing one by ID.

  void addOrUpdateRoom(ChatRoom room) {
    if (!rooms.value.any((r) => r.id == room.id)) {
      rooms.value = [...rooms.value, room];
    } else {
      rooms.value = rooms.value.map((r) => r.id == room.id ? room : r).toList();
    }
  }

  /// ❌ Removes a room from the list by ID.

  void removeRoom(String roomId) {
    rooms.value = rooms.value.where((r) => r.id != roomId).toList();
  }

  /// 🔍 Gets a room by its ID, or null if not found.

  ChatRoom? getRoomById(String roomId) {
    try {
      return rooms.value.firstWhere((r) => r.id == roomId);
    } catch (_) {
      return null;
    }
  }

  /// 🧹 Clears all rooms from the store.

  void clearRooms() => rooms.value = [];
}
