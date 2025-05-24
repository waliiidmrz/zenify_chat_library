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
        unsigned: {
          'reaction': {'@bob:chat.com': '❤️'}
        },
      ),
      Event(
        eventId: 'evt_img1',
        room: _mockRoom,
        senderId: '@bob:chat.com',
        originServerTs: now.subtract(Duration(minutes: 2)),
        content: {
          'body': 'image1.jpg',
          'msgtype': 'm.image',
          'url': 'mxc://server/image1',
          'info': {'mimetype': 'image/jpeg', 'size': 123456}
        },
        type: 'm.room.message',
        status: EventStatus.sent,
        unsigned: {
          'reaction': {'@alice:chat.com': '🔥', '@charlie:chat.com': '😍'}
        },
      ),
      Event(
        eventId: 'evt_file1',
        room: _mockRoom,
        senderId: '@charlie:chat.com',
        originServerTs: now.subtract(Duration(minutes: 3)),
        content: {
          'body': 'document.pdf',
          'msgtype': 'm.file',
          'url': 'mxc://server/document',
          'info': {'mimetype': 'application/pdf', 'size': 234567}
        },
        type: 'm.room.message',
        status: EventStatus.sent,
        unsigned: {
          'reaction': {'@alice:chat.com': '👍'}
        },
      ),
      Event(
        eventId: 'evt_video1',
        room: _mockRoom,
        senderId: '@dan:chat.com',
        originServerTs: now.subtract(Duration(minutes: 4)),
        content: {
          'body': 'video.mp4',
          'msgtype': 'm.video',
          'url': 'mxc://server/video',
          'info': {'mimetype': 'video/mp4', 'size': 345678}
        },
        type: 'm.room.message',
        status: EventStatus.sent,
        unsigned: {
          'reaction': {'@bob:chat.com': '👏'}
        },
      ),
    ];

    List<ChatRoom> mockRooms = List.generate(10, (index) {
      return ChatRoom(
        id: 'room$index',
        tileDetails: ChatRoomTile(
          id: 'room$index',
          displayName: 'Chat Room $index',
          lastMessage: 'Last message for room $index',
          isLastMessageSeen: index % 2 == 0,
          notificationCount: index % 3 == 0 ? index : 0,
          members: ['@user$index:chat.com'],
        ),
        members: ['@user$index:chat.com', '@you:chat.com'],
        room: _mockRoom,
        events: mockEvents,
      );
    });

    rooms.value = mockRooms;
    unreadRoomCount.value =
        mockRooms.where((r) => r.tileDetails.notificationCount > 0).length;
  }

  void setRooms(List<ChatRoom> newRooms) => rooms.value = List.from(newRooms);

  void addOrUpdateRoom(ChatRoom room) {
    if (!rooms.value.any((r) => r.id == room.id)) {
      rooms.value = [...rooms.value, room];
    } else {
      rooms.value = rooms.value.map((r) => r.id == room.id ? room : r).toList();
    }
    unreadRoomCount.value =
        rooms.value.where((r) => r.tileDetails.notificationCount > 0).length;
  }

  void removeRoom(String roomId) {
    rooms.value = rooms.value.where((r) => r.id != roomId).toList();
    unreadRoomCount.value =
        rooms.value.where((r) => r.tileDetails.notificationCount > 0).length;
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
    unreadRoomCount.value = 0;
  }
}
