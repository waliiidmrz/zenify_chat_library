import 'package:matrix/matrix.dart';

class Message {
  final String sender;
  final String content;
  final int? timestamp;
  final String? replyTo;
  final String? reaction;
  final EventStatus? status; 

  Message({
    required this.sender,
    required this.content,
    this.timestamp,
    this.replyTo,
    this.reaction,
    this.status,  
  });
}
