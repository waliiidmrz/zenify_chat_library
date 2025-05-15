import 'package:flutter/material.dart';
import 'package:zenify_chat/store/store_service.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'room_tile.dart';

class RoomListView extends StatelessWidget {
  final StoreService store;
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
                ? chatRoom.events.first.body
                : "No messages";

            return RoomTile(
              roomId: chatRoom.id,
              title: chatRoom.tileDetails.displayName,
              lastMessage: lastMsg,
              isSelected: isSelected,
              onTap: () => onTapRoom(chatRoom),
              onLongPress: () => onLongPressRoom(chatRoom),
            );
          },
        );
      },
    );
  }
}
