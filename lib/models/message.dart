import 'package:matrix/matrix.dart';

class Message {
  final String sender;
  final String content;
  final int? timestamp;
  final String? replyTo;
  final List<String> reactions;
  final EventStatus? status;
  final bool isSeenByOtherUser;
  final Event? originalEvent;

  Message({
    required this.sender,
    required this.content,
    required this.isSeenByOtherUser,
    this.timestamp,
    this.replyTo,
    required this.reactions,
    this.status,
    this.originalEvent,
  });
}
