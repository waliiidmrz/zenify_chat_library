import 'package:flutter/material.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'room_tile.dart';

class RoomListView extends StatelessWidget {
  final MockStoreService store;
  final Set<ChatRoom> selectedRooms;
  final bool isSelectionMode;
  final void Function(ChatRoom) onTapRoom;
  final void Function(ChatRoom) onLongPressRoom;
  final List<ChatRoom>? customRooms;

  const RoomListView({
    super.key,
    required this.store,
    required this.selectedRooms,
    required this.isSelectionMode,
    required this.onTapRoom,
    required this.onLongPressRoom,
    this.customRooms,
  });

  @override
  Widget build(BuildContext context) {
    final roomsToDisplay = customRooms ?? store.rooms.value;

    if (roomsToDisplay.isEmpty) {
      return const Center(child: Text("Aucune discussion disponible."));
    }

    return ListView.separated(
      itemCount: roomsToDisplay.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(
          color: Colors.grey.shade300,
          thickness: 1,
        ),
      ),
      itemBuilder: (context, index) {
        final chatRoom = roomsToDisplay[index];
        final tile = chatRoom.tileDetails;
        final isSelected = selectedRooms.contains(chatRoom);

        return RoomTile(
          roomId: chatRoom.id,
          title: tile.displayName,
          lastMessage: tile.lastMessage ?? 'No messages',
          isSelected: isSelected,
          onTap: () => onTapRoom(chatRoom),
          onLongPress: () => onLongPressRoom(chatRoom),
          isLastMessageSeen: tile.isLastMessageSeen,
          notificationCount: tile.notificationCount,
          isMuted: tile.isMuted,
          isBlocked: tile.isBlocked,
        );
      },
    );
  }
}
