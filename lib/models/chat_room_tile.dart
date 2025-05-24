class ChatRoomTile {
  final String id;
  final String displayName;
  String? lastMessage;
  final List<String>? members;
  bool isLastMessageSeen;
  final int notificationCount;

  ChatRoomTile({
    required this.id,
    required this.displayName,
    required this.isLastMessageSeen,
    this.lastMessage,
    this.members,
    this.notificationCount = 0,
  });
}
