import 'package:matrix/matrix.dart';
import 'package:zenify_chat/models/chat_room_tile.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'package:zenify_chat/models/message.dart';

// 🔁 Extension for ChatRoomTile
extension ChatRoomTileUtils on ChatRoomTile {
  ChatRoomTile copyWith({
    String? id,
    String? displayName,
    String? lastMessage,
    List<String>? members,
    bool? isLastMessageSeen,
    int? notificationCount,
  }) {
    return ChatRoomTile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      lastMessage: lastMessage ?? this.lastMessage,
      members: members ?? this.members,
      isLastMessageSeen: isLastMessageSeen ?? this.isLastMessageSeen,
      notificationCount: notificationCount ?? this.notificationCount,
    );
  }

  static ChatRoomTile empty(String id) => ChatRoomTile(
        id: id,
        displayName: '',
        isLastMessageSeen: true,
      );
}

// 🔁 Extension for ChatRoom
extension ChatRoomUtils on ChatRoom {
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

  static ChatRoom empty(String id) => ChatRoom(
        id: id,
        tileDetails: ChatRoomTileUtils.empty(id),
        events: [],
      );
}

// 🔁 Extension for Message
extension MessageUtils on Message {
  Message copyWith({
    String? sender,
    String? content,
    int? timestamp,
    String? replyTo,
    List<String>? reactions,
    EventStatus? status,
    bool? isSeenByOtherUser,
  }) {
    return Message(
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
      status: status ?? this.status,
      isSeenByOtherUser: isSeenByOtherUser ?? this.isSeenByOtherUser,
      originalEvent: originalEvent ?? this.originalEvent,
    );
  }

  static Message empty() => Message(
        sender: '',
        content: '',
        isSeenByOtherUser: false,
        reactions: [],
      );
}

extension ReactionSupport on Event {
  Event copyWithUserReaction(String sender, String emoji) {
    final updated = Event.fromJson(toJson(), room);

    final unsignedMap = updated.unsigned as Map<String, dynamic>;

    if (unsignedMap['reaction'] is! Map<String, String>) {
      unsignedMap['reaction'] = <String, String>{};
    }

    final reactionMap = unsignedMap['reaction'] as Map<String, String>;
    reactionMap[sender] = emoji;

    return updated;
  }

  String? getReactionFor(String sender) {
    final map = unsigned?['reaction'];
    if (map is Map<String, dynamic>) {
      return map[sender] as String?;
    }
    return null;
  }

  List<String> getAllReactions() {
    final map = unsigned?['reaction'];
    if (map is Map<String, dynamic>) {
      return map.values
          .whereType<String>()
          .toSet()
          .toList(); // use set to deduplicate emojis
    }
    return [];
  }
}
