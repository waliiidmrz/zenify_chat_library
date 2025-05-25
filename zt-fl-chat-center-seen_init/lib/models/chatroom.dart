import 'package:zenify_chat/models/chat_room_tile.dart';
import 'package:matrix/matrix.dart';

class ChatRoom {
  final String id;
  final ChatRoomTile tileDetails;
  final List<String>? members;
  final Room? room;
  final List<Event> events;

  ChatRoom({
    required this.id,
    required this.tileDetails,
    this.members,
    this.room,
    required this.events,
  });

  /// 🔥 Ajout de copyWith
  ChatRoom copyWith({
    String? id,
    ChatRoomTile? tileDetails,
    List<String>? members,
    Room? room,
    List<Event>? events,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      tileDetails: tileDetails ?? this.tileDetails,
      members: members ?? this.members,
      room: room ?? this.room,
      events: events ?? this.events,
    );
  }
}
