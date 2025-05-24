import 'package:flutter/material.dart';

/// 🧑 Avatar circle shown next to each message
class MessageAvatar extends StatelessWidget {
  final String initial;

  const MessageAvatar({super.key, required this.initial});

  @override
  Widget build(BuildContext context) {
    final letter = initial.isNotEmpty ? initial[0].toUpperCase() : "?";

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: Colors.blueAccent,
        child: Text(
          letter,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
