import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart';
import 'package:zenify_chat/models/chat_room_tile.dart';
import 'package:zenify_chat/models/chatroom.dart';

class MockStoreService {
  final Client _mockClient = Client('mock_client');
  late final Room _mockRoom;

  MockStoreService() {
    _mockRoom = Room(id: '!mockRoomId:chat.com', client: _mockClient);
    _initializeMockRooms();
  }

  final ValueNotifier<List<ChatRoom>> rooms = ValueNotifier([]);
  final ValueNotifier<int> unreadRoomCount = ValueNotifier(0);

  void _initializeMockRooms() {
    final now = DateTime.now();
    List<Event> mockEvents = [
      Event(
        eventId: 'evt_text1',
        room: _mockRoom,
        senderId: '@alice:chat.com',
        originServerTs: now.subtract(Duration(minutes: 1)),
        content: {'body': 'Hello there!', 'msgtype': 'm.text'},
        type: 'm.room.message',
        status: EventStatus.sent,
      ),
    ];

    rooms.value = List.generate(10, (index) {
      return ChatRoom(
        id: 'room$index',
        tileDetails: ChatRoomTile(
          id: 'room$index',
          displayName: 'Chat Room $index',
          lastMessage: 'Last message for room $index',
          isLastMessageSeen: index % 2 == 0,
          notificationCount: index % 3 == 0 ? index : 0,
          isMuted: false,
          isArchived: false,
          isBlocked: false,
        ),
        members: ['@user$index:chat.com', '@you:chat.com'],
        room: _mockRoom,
        events: mockEvents,
      );
    });

    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadRoomCount.value =
        rooms.value.where((r) => r.tileDetails.notificationCount > 0).length;
  }

  void markAsUnread(List<String> roomIds) {
    for (var id in roomIds) {
      final room = getRoomById(id);
      if (room != null) {
        final updatedTile = room.tileDetails.copyWith(isLastMessageSeen: false);
        addOrUpdateRoom(room.copyWith(tileDetails: updatedTile));
      }
    }
    _updateUnreadCount();
  }

  void archiveRooms(List<String> roomIds) {
    for (var id in roomIds) {
      final room = getRoomById(id);
      if (room != null) {
        final updatedTile = room.tileDetails.copyWith(isArchived: true);
        addOrUpdateRoom(room.copyWith(tileDetails: updatedTile));
      }
    }
  }

  void muteRooms(List<String> roomIds) {
    for (var id in roomIds) {
      final room = getRoomById(id);
      if (room != null) {
        final updatedTile = room.tileDetails.copyWith(isMuted: true);
        addOrUpdateRoom(room.copyWith(tileDetails: updatedTile));
      }
    }
  }

  void blockRooms(List<String> roomIds) {
    for (var id in roomIds) {
      final room = getRoomById(id);
      if (room != null) {
        final updatedTile = room.tileDetails.copyWith(isBlocked: true);
        addOrUpdateRoom(room.copyWith(tileDetails: updatedTile));
      }
    }
  }

  void deleteRooms(List<String> roomIds) {
    rooms.value = rooms.value.where((r) => !roomIds.contains(r.id)).toList();
    _updateUnreadCount();
  }

  void setRooms(List<ChatRoom> newRooms) {
    rooms.value = List.from(newRooms);
    _updateUnreadCount();
  }

  void addOrUpdateRoom(ChatRoom room) {
    final updatedList = List<ChatRoom>.from(rooms.value);
    final index = updatedList.indexWhere((r) => r.id == room.id);
    if (index == -1) {
      updatedList.add(room);
    } else {
      updatedList[index] = room;
    }
    rooms.value = updatedList; // 🟢 Notifie toujours les listeners
    _updateUnreadCount();
  }

  ChatRoom? getRoomById(String roomId) {
    try {
      return rooms.value.firstWhere((r) => r.id == roomId);
    } catch (_) {
      return null;
    }
  }

  void clearRooms() {
    rooms.value = [];
    _updateUnreadCount();
  }
}
