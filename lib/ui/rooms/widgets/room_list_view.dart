import 'package:flutter/material.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'room_tile.dart';

/// 📃 Displays a scrollable list of chat room tiles
class RoomListView extends StatelessWidget {
  final MockStoreService store;
  final Set<ChatRoom> selectedRooms;
  final bool isSelectionMode;
  final void Function(ChatRoom) onTapRoom;
  final void Function(ChatRoom) onLongPressRoom;

  const RoomListView({
    super.key,
    required this.store,
    required this.selectedRooms,
    required this.isSelectionMode,
    required this.onTapRoom,
    required this.onLongPressRoom,
  });

  @override
  Widget build(BuildContext context) {
    for (final chatroom in store.rooms.value) {
      print(
          "📱 UI rendering: ${chatroom.tileDetails.displayName} | 🔔 ${chatroom.tileDetails.notificationCount}");
    }

    return ValueListenableBuilder<List<ChatRoom>>(
      valueListenable: store.rooms,
      builder: (context, chatRooms, _) {
        if (chatRooms.isEmpty) {
          return const Center(child: Text("No rooms available"));
        }

        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            final isSelected = selectedRooms.contains(chatRoom);
            final lastMsg = chatRoom.events.isNotEmpty
                ? chatRoom.tileDetails.lastMessage
                : "No messages";

            return RoomTile(
              roomId: chatRoom.id,
              title: chatRoom.tileDetails.displayName,
              lastMessage: lastMsg!,
              isSelected: isSelected,
              onTap: () => onTapRoom(chatRoom),
              isLastMessageSeen: chatRoom.tileDetails.isLastMessageSeen,
              onLongPress: () => onLongPressRoom(chatRoom),
              notificationCount: chatRoom.tileDetails.notificationCount,
            );
          },
        );
      },
    );
  }
}
