import 'package:flutter/material.dart';

class RoomTile extends StatelessWidget {
  final String roomId;
  final String title;
  final String lastMessage;
  final bool isSelected;
  final bool isLastMessageSeen;
  final int notificationCount;
  final bool isMuted;
  final bool isBlocked;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

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
    this.isMuted = false,
    this.isBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? Colors.blue.withOpacity(0.2) : null,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color.fromARGB(255, 152, 184, 239), // Couleur de fond
          child: Icon(Icons.person, color: Colors.white, size: 28), // Icône bonhomme
          // OU pour un emoji : child: Text('👤', style: TextStyle(fontSize: 24))
        ),
        title: Row(
          children: [
            Expanded(child: Text(title)),
            if (isMuted) Icon(Icons.notifications_off, size: 16, color: Colors.grey),
            if (isBlocked) Icon(Icons.lock, size: 16, color: Colors.red),
          ],
        ),
        subtitle: Text(
          lastMessage,
          style: TextStyle(
            fontWeight: isLastMessageSeen ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        trailing: notificationCount > 0
            ? CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(
                  '$notificationCount',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            : null,
      ),
    );
  }
}
