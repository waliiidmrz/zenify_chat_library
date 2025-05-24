import 'package:flutter/material.dart';

/// 🔁 Shows the replied-to portion of a message if it begins with "> "
class MessageReplyPreview extends StatelessWidget {
  final String content;

  const MessageReplyPreview({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    if (!content.startsWith("> ")) return const SizedBox.shrink();

    final reply = content.split('\n').first.replaceFirst("> ", "");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: const Border(
          left: BorderSide(color: Colors.blueAccent, width: 4),
        ),
      ),
      child: Text(
        reply,
        style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
      ),
    );
  }
}
