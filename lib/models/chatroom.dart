import 'package:matrix/matrix.dart';
import 'package:zenify_chat/models/chat_room_tile.dart';

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
}
