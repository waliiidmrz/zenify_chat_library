import 'package:flutter/foundation.dart';
import 'package:zenify_chat/models/chatroom.dart';

class StoreService {
  final ValueNotifier<List<ChatRoom>> rooms = ValueNotifier([]);

  void setRooms(List<ChatRoom> newRooms) {
    rooms.value = List<ChatRoom>.from(newRooms);
  }

  void addOrUpdateRoom(ChatRoom room) {
    print("🧵 Adding or updating room: ${room.id}");
    for (var e in room.events) {
      print(
          "📦 RoomUpdate - [${e.body}] | status=${e.status} | eventId=${e.eventId}");
    }
    if (!rooms.value.any((r) => r.id == room.id)) {
      rooms.value = [...rooms.value, room];
    } else {
      rooms.value = rooms.value.map((r) => r.id == room.id ? room : r).toList();
    }
  }

  void removeRoom(String roomId) {
    rooms.value = rooms.value.where((r) => r.id != roomId).toList();
  }

  ChatRoom? getRoomById(String roomId) {
    try {
      return rooms.value.firstWhere((r) => r.id == roomId);
    } catch (_) {
      return null;
    }
  }

  void clearRooms() => rooms.value = [];
}
