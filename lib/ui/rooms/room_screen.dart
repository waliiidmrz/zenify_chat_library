import 'package:flutter/material.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'package:zenify_chat/store/store_service.dart';
import 'package:zenify_chat/ui/chat/chat_screen.dart';
import 'package:zenify_chat/ui/create_chat_room/create_chat_screen.dart';
import 'package:zenify_chat/ui/rooms/widgets/room_list_view.dart';
import 'package:zenify_chat/ui/rooms/widgets/rooms_app_bar.dart';

class RoomsScreen extends StatefulWidget {
  final StoreService store;
  final String? initialRoomId;

  const RoomsScreen({
    super.key,
    required this.store,
    this.initialRoomId,
  });

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  Set<ChatRoom> selectedRooms = {};
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialRoomId != null) {
        final rooms = widget.store.rooms.value;
        final room = rooms.firstWhere(
          (r) => r.id == widget.initialRoomId,
          orElse: () => rooms.first,
        );
        _navigateToChat(room);
      }
    });
  }

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

  void _onTapRoom(ChatRoom room) {
    if (isSelectionMode) {
      setState(() {
        selectedRooms.contains(room)
            ? selectedRooms.remove(room)
            : selectedRooms.add(room);
        if (selectedRooms.isEmpty) isSelectionMode = false;
      });
    } else {
      _navigateToChat(room);
    }
  }

  void _onLongPressRoom(ChatRoom room) {
    setState(() {
      isSelectionMode = true;
      selectedRooms.add(room);
    });
  }

  void _clearSelection() {
    setState(() {
      isSelectionMode = false;
      selectedRooms.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: RoomsAppBar(
        isSelectionMode: isSelectionMode,
        selectedCount: selectedRooms.length,
        onClearSelection: _clearSelection,
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
