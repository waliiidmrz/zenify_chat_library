import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:zenify_chat/store/store_service.dart';
import 'package:zenify_chat/ui/rooms/room_screen.dart';

/// Pure navigation helper: only responsible for UI navigation and feedback.
void navigateToRoom({
  required BuildContext context,
  required Room room,
  required StoreService store,
  required bool created,
}) {
  final String bannerText = created
      ? "🎉 Room created — you can start chatting now!"
      : "⚠️ Room already exists — opening chat";
  final Color bannerColor = created ? Colors.green : Colors.orange.shade600;

  _showSnack(context, bannerText, bannerColor);
  print("🧭 Navigating to room screen for: ${room.id} (${room.name})");

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => RoomsScreen(
        store: store,
        initialRoomId: room.id,
      ),
    ),
    (_) => false,
  );
}

void _showSnack(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ),
  );
}
