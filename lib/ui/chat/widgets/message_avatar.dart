import 'package:flutter/material.dart';

class MessageAvatar extends StatelessWidget {
  final String initial;

  const MessageAvatar({super.key, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: Colors.blueAccent,
        child: Text(initial,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }
}
