import 'package:flutter/material.dart';

bool validateRoomName(BuildContext context, String roomName) {
  if (roomName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("⚠️ Please enter a room name")),
    );
    return false;
  }
  return true;
}
