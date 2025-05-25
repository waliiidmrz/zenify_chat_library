import 'package:flutter/material.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'package:zenify_chat/services/auth_service.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/ui/chat/chat_screen.dart';
import 'package:zenify_chat/ui/create_chat_room/create_chat_screen.dart';
import 'package:zenify_chat/ui/rooms/widgets/room_list_view.dart';
import 'archived_chats_screen.dart';
import 'blocked_chats_screen.dart';

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
  String searchQuery = '';

  void _onTapRoom(ChatRoom room) {
    if (isSelectionMode) {
      _toggleRoomSelection(room);
    } else {
      _navigateToChat(room);
    }
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

  void _onLongPressRoom(ChatRoom room) {
    if (!isSelectionMode) {
      _showSingleRoomActions(room);
    } else {
      _toggleRoomSelection(room);
    }
  }

  void _showSingleRoomActions(ChatRoom room) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.markunread),
              title: Text('Marquer comme non lue'),
              onTap: () {
                Navigator.pop(context);
                widget.store.markAsUnread([room.id]);
              },
            ),
            ListTile(
              leading: Icon(Icons.archive),
              title: Text('Archiver'),
              onTap: () {
                Navigator.pop(context);
                widget.store.archiveRooms([room.id]);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_off),
              title: Text('Mettre en sourdine'),
              onTap: () {
                Navigator.pop(context);
                widget.store.muteRooms([room.id]);
              },
            ),
            ListTile(
              leading: Icon(Icons.block),
              title: Text('Bloquer'),
              onTap: () {
                Navigator.pop(context);
                widget.store.blockRooms([room.id]);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Supprimer la discussion'),
              onTap: () {
                Navigator.pop(context);
                widget.store.deleteRooms([room.id]);
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleRoomSelection(ChatRoom room) {
    setState(() {
      selectedRooms.contains(room)
          ? selectedRooms.remove(room)
          : selectedRooms.add(room);
      if (selectedRooms.isEmpty) isSelectionMode = false;
    });
  }

  void _clearSelection() {
    setState(() {
      isSelectionMode = false;
      selectedRooms.clear();
    });
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    widget.onLogout?.call();
  }

  void _activateSelectionMode() {
    setState(() {
      isSelectionMode = true;
    });
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Paramètres'),
          content: Text('Paramètres à venir...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showSelectionActions() {
    if (selectedRooms.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.markunread),
              title: Text('Marquer comme non lue (${selectedRooms.length})'),
              onTap: () {
                Navigator.pop(context);
                widget.store.markAsUnread(selectedRooms.map((r) => r.id).toList());
                _clearSelection();
              },
            ),
            ListTile(
              leading: Icon(Icons.archive),
              title: Text('Archiver (${selectedRooms.length})'),
              onTap: () {
                Navigator.pop(context);
                widget.store.archiveRooms(selectedRooms.map((r) => r.id).toList());
                _clearSelection();
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_off),
              title: Text('Mettre en sourdine (${selectedRooms.length})'),
              onTap: () {
                Navigator.pop(context);
                widget.store.muteRooms(selectedRooms.map((r) => r.id).toList());
                _clearSelection();
              },
            ),
            ListTile(
              leading: Icon(Icons.block),
              title: Text('Bloquer (${selectedRooms.length})'),
              onTap: () {
                Navigator.pop(context);
                widget.store.blockRooms(selectedRooms.map((r) => r.id).toList());
                _clearSelection();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Supprimer (${selectedRooms.length})'),
              onTap: () {
                Navigator.pop(context);
                widget.store.deleteRooms(selectedRooms.map((r) => r.id).toList());
                _clearSelection();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: AppBar(
        title: const Text("Vos discussions"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: _showSelectionActions,
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _clearSelection,
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: _activateSelectionMode,
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.menu),
              onSelected: (value) {
                if (value == 'settings') {
                  _openSettings();
                } else if (value == 'archived') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ArchivedChatsScreen(store: widget.store)),
                  );
                } else if (value == 'blocked') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BlockedChatsScreen(store: widget.store)),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Paramètres'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'archived',
                  child: Row(
                    children: [
                      Icon(Icons.archive, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Discussions archivées'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'blocked',
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Discussions bloquées'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Rechercher un room...",
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() => searchQuery = value.toLowerCase());
                },
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<ChatRoom>>(
              valueListenable: widget.store.rooms,
              builder: (context, allRooms, _) {
                final filteredRooms = allRooms
                    .where((room) =>
                        room.tileDetails.displayName.toLowerCase().contains(searchQuery) &&
                        !room.tileDetails.isArchived &&
                        !room.tileDetails.isBlocked)
                    .toList();

                return RoomListView(
                  store: widget.store,
                  selectedRooms: selectedRooms,
                  isSelectionMode: isSelectionMode,
                  onTapRoom: _onTapRoom,
                  onLongPressRoom: _onLongPressRoom,
                  customRooms: filteredRooms,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 176, 205, 253),
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
