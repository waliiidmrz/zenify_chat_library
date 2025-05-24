import 'package:flutter/material.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'package:zenify_chat/services/auth_service.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/ui/chat/chat_screen.dart';
import 'package:zenify_chat/ui/create_chat_room/create_chat_screen.dart';
import 'package:zenify_chat/ui/rooms/widgets/room_list_view.dart';
import 'package:zenify_chat/ui/rooms/widgets/rooms_app_bar.dart';

/// 🏠 Displays the list of joined chat rooms
class RoomsScreen extends StatefulWidget {
  final MockStoreService store;
  final String? initialRoomId;
  final VoidCallback? onLogout;

  const RoomsScreen({
    super.key,
    required this.store,
    this.initialRoomId,
    this.onLogout,
  });

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  Set<ChatRoom> selectedRooms = {};
  bool isSelectionMode = false;

  /// 🔁 Handles tap on a room tile
  void _onTapRoom(ChatRoom room) {
    if (isSelectionMode) {
      _toggleRoomSelection(room);
    } else {
      _navigateToChat(room);
    }
  }

  /// 📍 Navigates to individual chat screen
  void _navigateToChat(ChatRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatRoomid: room.id,
          store: widget.store,
        ),
      ),
    );
  }

  /// 🧭 Triggered by long press to start selection mode
  void _onLongPressRoom(ChatRoom room) {
    setState(() {
      isSelectionMode = true;
      selectedRooms.add(room);
    });
  }

  /// 🔁 Select/unselect a room
  void _toggleRoomSelection(ChatRoom room) {
    setState(() {
      selectedRooms.contains(room)
          ? selectedRooms.remove(room)
          : selectedRooms.add(room);
      if (selectedRooms.isEmpty) isSelectionMode = false;
    });
  }

  /// ❌ Clears all selected rooms and exits selection mode
  void _clearSelection() {
    setState(() {
      isSelectionMode = false;
      selectedRooms.clear();
    });
  }

  /// 🚪 Logs the user out via AuthService
  Future<void> _handleLogout() async {
    await AuthService.logout();
    widget.onLogout?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: RoomsAppBar(
        isSelectionMode: isSelectionMode,
        selectedCount: selectedRooms.length,
        onClearSelection: _clearSelection,
        onLogout: _handleLogout,
      ),
      body: RoomListView(
        store: widget.store,
        selectedRooms: selectedRooms,
        isSelectionMode: isSelectionMode,
        onTapRoom: _onTapRoom,
        onLongPressRoom: _onLongPressRoom,
      ),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add_comment),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateChatScreen(),
                  ),
                );
              },
            ),
    );
  }
}
