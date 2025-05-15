 

class ChatRoomTile {
  final String id; 
  final String displayName;
  String? lastMessage;
  final List<String>? members;

  ChatRoomTile(
      {required this.id,
      required this.displayName,
      this.lastMessage,
      this.members,});
}
