import 'package:flutter/material.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/ui/rooms/room_screen.dart';

/// 📌 App bar shown in the chat screen, with navigation to the room list.
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final MockStoreService store;
  final String roomId;

  const ChatAppBar({
    super.key,
    required this.title,
    required this.roomId,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title.isEmpty ? "Chat" : title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomsScreen(
              store: store,
              initialRoomId: roomId,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
