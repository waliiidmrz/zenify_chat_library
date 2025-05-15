import 'package:matrix/matrix.dart';
import 'package:zenify_chat/models/message.dart';

Message mapEventToMessage(Event event) {
  return Message(
    sender: event.senderId,
    content: event.body,
    timestamp: event.originServerTs.millisecondsSinceEpoch,
    status: event.status,
  );
}
