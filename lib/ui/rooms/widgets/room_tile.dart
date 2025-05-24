import 'package:flutter/material.dart';
import 'package:zenify_chat/ui/rooms/utils/date_utils.dart';

/// 🧱 A single tile representing a room inside RoomListView
class RoomTile extends StatelessWidget {
  final String roomId;
  final String title;
  final String lastMessage;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isLastMessageSeen;
  final int notificationCount;

  const RoomTile({
    super.key,
    required this.roomId,
    required this.title,
    required this.lastMessage,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.isLastMessageSeen,
    required this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.chat, color: Colors.white),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight:
                  isLastMessageSeen ? FontWeight.normal : FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (notificationCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                formatRoomDate(null),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
