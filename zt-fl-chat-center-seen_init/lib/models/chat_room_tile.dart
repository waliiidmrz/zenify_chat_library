class ChatRoomTile {
  final String id;
  final String displayName;
  String? lastMessage;
  final List<String>? members;
  bool isLastMessageSeen;
  final int notificationCount;
  final bool isMuted;
  final bool isArchived;
  final bool isBlocked;

  ChatRoomTile({
    required this.id,
    required this.displayName,
    required this.isLastMessageSeen,
    this.lastMessage,
    this.members,
    this.notificationCount = 0,
    this.isMuted = false,
    this.isArchived = false,
    this.isBlocked = false,
  });

  ChatRoomTile copyWith({
    String? id,
    String? displayName,
    String? lastMessage,
    List<String>? members,
    bool? isLastMessageSeen,
    int? notificationCount,
    bool? isMuted,
    bool? isArchived,
    bool? isBlocked,
  }) {
    return ChatRoomTile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      lastMessage: lastMessage ?? this.lastMessage,
      members: members ?? this.members,
      isLastMessageSeen: isLastMessageSeen ?? this.isLastMessageSeen,
      notificationCount: notificationCount ?? this.notificationCount,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
