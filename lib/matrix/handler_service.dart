import 'dart:collection';
import 'package:matrix/matrix.dart';
import 'package:collection/collection.dart';
import 'package:zenify_chat/matrix/matrix_client_service.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/models/utils/model_extensions.dart';

/// 📦 Handles real-time Matrix events (e.g., new messages, receipts)
/// Ensures ordered processing via a queue, updates `StoreService`.
class MatrixEventHandlersService {
  final Client client;
  final MockStoreService store;
  final MatrixClientService matrixClientService = MatrixClientService();

  final Queue<QueuedEvent> eventQueue = Queue();
  String? _lastEventType;
  bool _isProcessing = false;

  MatrixEventHandlersService({
    required this.client,
    required this.store,
  });

  /// 🔄 Initializes listeners for timeline events
  void init() {
    print("🧵 MatrixEventHandlersService initialized");

    client.onTimelineEvent.stream.listen((event) {
      final room = event.room;

      eventQueue.add(QueuedEvent(event, room));
      processQueue(); // Begin queue processing
    });
    listenToReadReceiptsOnSync();
  }

  /// 🌀 Serial queue processor that ensures one event is handled at a time.
  void processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (eventQueue.isNotEmpty) {
      final queued = eventQueue.removeFirst();

      // Introduce delay if processing similar event types back to back
      if (_lastEventType == queued.event.type) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      try {
        await _handleEvent(queued.event, queued.room);
        _lastEventType = queued.event.type;
      } catch (e) {
        print("❌ Error while processing event: $e");
      }
    }

    _isProcessing = false;
  }

  /// 🧠 Main event handler - routes events to appropriate processors.
  Future<void> _handleEvent(Event event, Room room) async {
    switch (event.type) {
      case EventTypes.Message:
        await _handleNewMessage(event, room);
        break;
      case EventTypes.Reaction:
        await _handleReaction(event, room);
        break;

      // future: handle member joins, reactions, etc.
      default:
        break;
    }
  }

  /// 💬 Handles incoming Matrix message events and updates chat store.
  Future<void> _handleNewMessage(Event event, Room room) async {
    print("📩 Received new event:");
    print("🔹 eventId: ${event.eventId}");
    print("🔹 type: ${event.type}");
    print("🔹 msgtype: ${event.messageType}");
    print("🔹 status: ${event.status.name}");
    print("🔹 hasAttachment: ${event.hasAttachment}");
    print("🔹 mimeType: ${event.attachmentMimetype}");
    print("🔹 body: '${event.body}'");

    if (event.hasAttachment) {
      return await _handleMediaMessage(event, room);
    }
    final stored = store.getRoomById(room.id);
    if (stored == null) {
      print("❗ Room not found in store: ${room.id}");
      return;
    }

    final clonedEvents = [...stored.events];

    // Step 1: Try matching event by ID
    int index = clonedEvents.indexWhere((e) => e.eventId == event.eventId);

    // Step 2: If it's a confirmation, try matching by body
    if (index == -1 &&
        (event.status == EventStatus.sent ||
            event.status == EventStatus.synced)) {
      index = clonedEvents.indexWhere(
        (e) =>
            e.status == EventStatus.sending &&
            e.body.trim() == event.body.trim(),
      );
    }

    // Step 3: Replace or insert
    if (index != -1) {
      print("♻️ Replacing existing event at index $index");
      clonedEvents[index] = event;
    } else {
      print("➕ Inserting new event at top");

      final isDuplicate = clonedEvents.any((e) => e.eventId == event.eventId);
      if (!isDuplicate) {
        clonedEvents.insert(0, event); // Insert at beginning (latest first)
      } else {
        print("⚠️ Skipping duplicate insert for: ${event.eventId}");
      }
    }

    final latestEvent = clonedEvents.first;
    final latestSeenId = room.receiptState.global.latestOwnReceipt?.eventId;
    final lastSeen = latestEvent.senderId == client.userID ||
        latestEvent.eventId == latestSeenId;

    final updatedTile = stored.tileDetails.copyWith(
      lastMessage: latestEvent.body,
      isLastMessageSeen: lastSeen,
      notificationCount: room.notificationCount,
    );

    final updatedRoom = ChatRoom(
      id: stored.id,
      tileDetails: updatedTile,
      room: stored.room,
      members: stored.members,
      events: clonedEvents,
    );

    store.addOrUpdateRoom(updatedRoom);
  }

  Future<void> _handleReaction(Event event, Room room) async {
    final relatesTo = event.content['m.relates_to'] as Map<String, dynamic>?;

    if (relatesTo == null ||
        relatesTo['rel_type'] != 'm.annotation' ||
        relatesTo['event_id'] == null ||
        relatesTo['key'] == null) {
      print("⚠️ Invalid reaction event received: ${event.eventId}");
      return;
    }

    final targetId = relatesTo['event_id'] as String;
    final emoji = relatesTo['key'] as String;
    final sender = event.senderId;

    final stored = store.getRoomById(room.id);
    if (stored == null) return;

    final updatedEvents = [...stored.events];

    final targetIndex = updatedEvents.indexWhere((e) => e.eventId == targetId);
    if (targetIndex == -1) {
      print("⚠️ Reaction refers to unknown event: $targetId");
      return;
    }

    final targetEvent = updatedEvents[targetIndex];

    // ✅ Cast relates_to when accessing nested fields
    final allReactions = stored.events.where((e) {
      if (e.type != EventTypes.Reaction || e.senderId != sender) return false;
      final content = e.content;
      final rel = content['m.relates_to'];
      if (rel is Map<String, dynamic>) {
        return rel['event_id'] == targetId;
      }
      return false;
    });

    final latest = allReactions.lastOrNull;

    final latestRelatesTo = latest?.content['m.relates_to'];
    if (latestRelatesTo is Map<String, dynamic>) {
      latestRelatesTo['key'] as String?;
    }

    final newEvent = targetEvent.copyWithUserReaction(sender, emoji);
    updatedEvents[targetIndex] = newEvent;

    final updatedRoom = stored.copyWith(events: updatedEvents);
    print(
        "🎯 _handleReaction → event: ${event.eventId} | emoji: $emoji | status : ${event.status} | target: $targetId | from: $sender");

    store.addOrUpdateRoom(updatedRoom);
  }

  void listenToReadReceiptsOnSync() {
    client.onSync.stream.listen((_) {
      for (final room in client.rooms) {
        updateSeenStatusForRoom(room);
      }
    });
  }

  /// ✅ Updates read receipt status for a room.
  void updateSeenStatusForRoom(Room room) {
    final stored = store.getRoomById(room.id);
    if (stored == null || stored.events.isEmpty) return;

    final lastEvent = stored.events.first;
    final lastSeen = lastEvent.senderId == client.userID ||
        room.receiptState.global.latestOwnReceipt?.eventId == lastEvent.eventId;

    final updatedTile = stored.tileDetails.copyWith(
      isLastMessageSeen: lastSeen,
      notificationCount: room.notificationCount,
    );

    store.addOrUpdateRoom(stored.copyWith(tileDetails: updatedTile));
  }

  Future<void> _handleMediaMessage(Event event, Room room) async {
    print("📸 Handling image event: ${event.eventId}");
    print("🔹 type: ${event.type}");
    print("🔹 msgtype: ${event.messageType}");
    print("🔹 status: ${event.status.name}");
    print("🔹 hasAttachment: ${event.hasAttachment}");
    print("🔹 mimeType: ${event.attachmentMimetype}");
    print("🔹 body: '${event.body}'");
    final isImage = event.attachmentMimetype.startsWith('image/');
    final isVideo = event.attachmentMimetype.startsWith('video/');
    final isPdf = event.attachmentMimetype == 'application/pdf';

    final stored = store.getRoomById(room.id);
    if (stored == null) {
      print("❗ Room not found in store for image: ${room.id}");
      return;
    }

    final clonedEvents = [...stored.events];
    print("📦 Current event count: ${clonedEvents.length}");

    // Step 1: Direct match by eventId
    int index = clonedEvents.indexWhere((e) => e.eventId == event.eventId);

    // Step 2: Match placeholder by txid
    final txid = event.unsigned?['transaction_id'];
    print("📦 transaction_id: $txid");

    if (index == -1 && txid != null) {
      index = clonedEvents.indexWhere(
        (e) =>
            e.status == EventStatus.sending &&
            e.unsigned?['transaction_id'] == txid,
      );
      print("🔄 Matched placeholder by txid? index=$index");
    }

    // Step 3: Fallback match by metadata
    if (index == -1 &&
        (event.status == EventStatus.synced ||
            event.status == EventStatus.sent)) {
      index = clonedEvents.indexWhere((e) =>
          e.status == EventStatus.sending &&
          e.body.trim() == event.body.trim() &&
          e.senderId == event.senderId &&
          (event.originServerTs.difference(e.originServerTs).inSeconds).abs() <
              20);
      print("🔍 Fallback match by content/timestamp? index=$index");
    }

    // Replace or insert
    if (index != -1) {
      print("♻️ Replacing existing image event at index $index");
      clonedEvents[index] = event;
    } else {
      final isDuplicate = clonedEvents.any((e) => e.eventId == event.eventId);
      if (!isDuplicate) {
        print("➕ Inserting new image event");
        clonedEvents.insert(0, event); // Newest at top
      } else {
        print("⚠️ Duplicate media message skipped: ${event.eventId}");
      }
    }

    final latestEvent = clonedEvents.first;
    final latestSeenId = room.receiptState.global.latestOwnReceipt?.eventId;
    final lastSeen = latestEvent.senderId == client.userID ||
        latestEvent.eventId == latestSeenId;

    final mime = latestEvent.attachmentMimetype;
    final bodyPreview = mime.startsWith("image/")
        ? "📷 Image"
        : mime.startsWith("video/")
            ? "🎥 Video"
            : "📄 File";

    final updatedTile = stored.tileDetails.copyWith(
      lastMessage: bodyPreview,
      isLastMessageSeen: lastSeen,
      notificationCount: room.notificationCount,
    );

    final updatedRoom = ChatRoom(
      id: stored.id,
      tileDetails: updatedTile,
      room: stored.room,
      members: stored.members,
      events: clonedEvents,
    );

    store.addOrUpdateRoom(updatedRoom);
  }
}

/// 📦 Helper model for queueing event-room pairs
class QueuedEvent {
  final Event event;
  final Room room;

  QueuedEvent(this.event, this.room);
}
