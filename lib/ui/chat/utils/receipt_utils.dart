import 'package:matrix/matrix.dart';

/// ✅ Marks last read message and stores it in local Matrix database
Future<void> markRoomAsRead(Room room) async {
  final lastEventId = room.lastEvent?.eventId;
  if (lastEventId == null) return;

  print("📍 Sending read marker for: $lastEventId");
  await room.setReadMarker(null, mRead: lastEventId);

  final now = DateTime.now().millisecondsSinceEpoch;
  final receiptState = room.receiptState;

  receiptState.global.latestOwnReceipt = LatestReceiptStateData(
    lastEventId,
    now,
  );

  final newAccountData = BasicEvent(
    type: LatestReceiptState.eventType,
    content: receiptState.toJson() as Map<String, Object?>,
  );

  room.roomAccountData[LatestReceiptState.eventType] = newAccountData;

  await room.client.database?.storeRoomAccountData(room.id, newAccountData);

  print("💽 Persisted latestOwnReceipt to database for room ${room.id}");
  print("🗂️ Updated roomAccountData with latestReceipt: $lastEventId at $now");
}
