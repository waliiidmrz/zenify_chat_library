import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matrix/matrix.dart';
import 'package:zenify_chat/models/message.dart';
import 'message_reply_preview.dart';

class MessageContainer extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool isSelected;

  const MessageContainer({
    super.key,
    required this.message,
    required this.isMe,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final content = message.content.trim().split('\n').last;

    return IntrinsicWidth(
      stepWidth: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getBubbleColor(),
          borderRadius: _buildRadius(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MessageReplyPreview(content: message.content),
            Text(content, style: const TextStyle(fontSize: 15)),
            if (message.reaction != null) _buildReaction(),
            const SizedBox(height: 6),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  BorderRadius _buildRadius() {
    return BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(isMe ? 0 : 12),
      bottomRight: Radius.circular(isMe ? 12 : 0),
    );
  }

  Widget _buildFooter() {
    final time = DateFormat.Hm().format(
      DateTime.fromMillisecondsSinceEpoch(message.timestamp ?? 0),
    );

    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(time,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          const SizedBox(width: 6),
          _buildStatusIcon(message.status),
        ],
      ),
    );
  }

  Widget _buildReaction() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        message.reaction!,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Color _getBubbleColor() {
    if (isSelected) return Colors.blue.shade100;

    switch (message.status) {
      case EventStatus.sending:
        return Colors.orange.shade100;
      case EventStatus.sent:
        return Colors.grey.shade200;
      case EventStatus.synced:
        return isMe ? const Color(0xFFDCF8C6) : Colors.white;
      default:
        return isMe ? const Color(0xFFDCF8C6) : Colors.white;
    }
  }

  Widget _buildStatusIcon(EventStatus? status) {
    switch (status) {
      case EventStatus.sending:
        return const Icon(Icons.access_time, size: 12, color: Colors.orange);
      case EventStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.grey);
      case EventStatus.synced:
        return const Icon(Icons.done_all, size: 12, color: Colors.green);
      default:
        return const SizedBox.shrink();
    }
  }
}
