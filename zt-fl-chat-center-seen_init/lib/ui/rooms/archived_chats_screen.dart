import 'package:flutter/material.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/models/chatroom.dart';

class ArchivedChatsScreen extends StatelessWidget {
  final MockStoreService store;
  const ArchivedChatsScreen({super.key, required this.store});

  void _onLongPressRoom(BuildContext context, ChatRoom room) {
    print('📌 Long press detected on archived room ${room.id}');
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.unarchive),
              title: Text('Désarchiver'),
              onTap: () {
                Navigator.pop(context);
                final updatedTile = room.tileDetails.copyWith(isArchived: false);
                store.addOrUpdateRoom(room.copyWith(tileDetails: updatedTile));
                print('✅ Room ${room.id} unarchived and updated.');
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
      appBar: AppBar(title: const Text('Discussions archivées')),
      body: ValueListenableBuilder<List<ChatRoom>>(
        valueListenable: store.rooms,
        builder: (context, allRooms, _) {
          final archivedRooms = allRooms.where((r) => r.tileDetails.isArchived).toList();

          if (archivedRooms.isEmpty) {
            return const Center(child: Text("Aucune discussion archivée."));
          }

          return ListView.builder(
            itemCount: archivedRooms.length,
            itemBuilder: (context, index) {
              final room = archivedRooms[index];

              return GestureDetector(
                onLongPress: () => _onLongPressRoom(context, room),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/default_avatar.png'),
                  ),
                  title: Text(room.tileDetails.displayName),
                  subtitle: Text(room.tileDetails.lastMessage ?? 'No messages'),
                  trailing: Icon(Icons.archive, color: Colors.blue), // Icône archivé
                  onTap: () {}, // Optionnel : ouvrir le chat
                ),
              );
            },
          );
        },
      ),
    );
  }
}
