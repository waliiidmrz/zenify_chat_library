import 'package:flutter/material.dart';

/// 📌 App bar for the room list screen
class RoomsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onClearSelection;
  final VoidCallback? onLogout;

  const RoomsAppBar({
    super.key,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onClearSelection,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return isSelectionMode
        ? AppBar(
            backgroundColor: Colors.blueAccent,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClearSelection,
            ),
            title: Text("$selectedCount selected"),
            actions: const [
              IconButton(icon: Icon(Icons.archive_outlined), onPressed: null),
              IconButton(icon: Icon(Icons.delete_outline), onPressed: null),
              IconButton(icon: Icon(Icons.push_pin_outlined), onPressed: null),
            ],
          )
        : AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == '/landing',
                );
              },
            ),
            title: Row(
              children: const [
                Icon(Icons.travel_explore, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  "Your Chats",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              if (onLogout != null)
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.black87),
                  onPressed: onLogout,
                ),
            ],
          );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
