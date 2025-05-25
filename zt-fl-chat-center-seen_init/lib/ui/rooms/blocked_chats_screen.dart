import 'package:flutter/material.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'widgets/room_list_view.dart';

class BlockedChatsScreen extends StatelessWidget {
  final MockStoreService store;
  const BlockedChatsScreen({super.key, required this.store});

  void _onLongPressRoom(BuildContext context, ChatRoom room) {
    print('📌 Long press detected on room ${room.id}');
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.lock_open),
              title: Text('Débloquer'),
              onTap: () {
                Navigator.pop(context);
                final updatedTile = room.tileDetails.copyWith(isBlocked: false);
                store.addOrUpdateRoom(room.copyWith(tileDetails: updatedTile));
                print('✅ Room ${room.id} unblocked and updated.');
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
      appBar: AppBar(title: const Text('Discussions bloquées')),
      body: ValueListenableBuilder<List<ChatRoom>>(
        valueListenable: store.rooms,
        builder: (context, allRooms, _) {
          final blockedRooms = allRooms.where((r) => r.tileDetails.isBlocked).toList();

          if (blockedRooms.isEmpty) {
            return const Center(child: Text("Aucune discussion bloquée."));
          }

          return ListView.builder(
            itemCount: blockedRooms.length,
            itemBuilder: (context, index) {
              final room = blockedRooms[index];

              return GestureDetector(
                onLongPress: () => _onLongPressRoom(context, room), // 🔥 Assure le déclenchement
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/default_avatar.png'),
                  ),
                  title: Text(room.tileDetails.displayName),
                  subtitle: Text(room.tileDetails.lastMessage ?? 'No messages'),
                  trailing: Icon(Icons.lock, color: Colors.red), // Icône bloqué
                  onTap: () {}, // Optionnel : tu peux ouvrir le chat ici
                ),
              );
            },
          );
        },
      ),
    );
  }
}
