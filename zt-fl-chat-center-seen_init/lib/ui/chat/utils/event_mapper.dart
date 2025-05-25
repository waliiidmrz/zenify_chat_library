import 'package:matrix/matrix.dart';
import 'package:zenify_chat/models/message.dart';
import 'package:zenify_chat/models/utils/model_extensions.dart'; // ← new file for ReactionSupport

Message mapEventToMessage(Event event) {
  final clientUserId = event.room.client.userID;
  final seenByOthers = event.receipts.any(
    (receipt) => receipt.user.id != clientUserId,
  );

  final allReactions = event.getAllReactions();

  return Message(
    sender: event.senderId,
    content: event.body,
    timestamp: event.originServerTs.millisecondsSinceEpoch,
    status: event.status,
    isSeenByOtherUser: seenByOthers,
    reactions: allReactions,
    originalEvent: event,
  );
}
