import 'dart:collection';
import 'package:matrix/matrix.dart';
import 'package:zenify_chat/matrix/matrix_client_service.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'package:zenify_chat/store/store_service.dart';
import 'package:collection/collection.dart';

class MatrixEventHandlersService {
  final Client client;
  final StoreService store;
  final MatrixClientService matrixClientService = MatrixClientService();
  String? _lastEventType;

  final Queue<_QueuedEvent> _eventQueue = Queue();
  bool _isProcessing = false;

  MatrixEventHandlersService({
    required this.client,
    required this.store,
  });

  void init() {
    print("🧵 MatrixEventHandlersService initialized");

    client.onTimelineEvent.stream.listen((event) {
      final Room? room = event.room;
      if (room == null) return;

      _eventQueue.add(_QueuedEvent(event, room));
      _processQueue();
    });

    // client.onSync.stream.listen((_) => _handleSync());
  }

  // Queue Processor
  void _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (_eventQueue.isNotEmpty) {
      final queued = _eventQueue.removeFirst();

      // ⏱ Add delay if event type matches previous
      if (_lastEventType == queued.event.type) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      try {
        await _handleEvent(queued.event, queued.room);
        _lastEventType = queued.event.type; // update last type
      } catch (e) {
        print("❌ Error while processing event: $e");
      }
    }

    _isProcessing = false;
  }

  // Async event handler
  Future<void> _handleEvent(Event event, Room room) async {
    print(
        "🧵 Handling: ${event.type} (${event.status})    eventid :    [${event.eventId}]");

    switch (event.type) {
      case EventTypes.Message:
        await _handleNewMessage(event, room);
        break;

      default:
        break;
    }
  }

  Future<void> _handleNewMessage(Event event, Room room) async {
    final stored = store.getRoomById(room.id);
    if (stored == null) {
      print("❗ Room not found in store: ${room.id}");
      return;
    }

    final clonedEvents = [...stored.events];

    final previousEvent = clonedEvents.firstWhereOrNull(
      (e) =>
          e.eventId == event.eventId || e.transactionId == event.transactionId,
    );

    if (previousEvent != null) {
      print(
          "🔁 Previous status: ${previousEvent.status}, New: ${event.status}");
    }
    // Step 1: Try to match by eventId (ideal)
    int index = clonedEvents.indexWhere((e) => e.eventId == event.eventId);

    // Step 2: If it's a sent/synced confirmation and not found, try body match
    if (index == -1 &&
        (event.status == EventStatus.sent ||
            event.status == EventStatus.synced)) {
      index = clonedEvents.indexWhere((e) =>
          e.status == EventStatus.sending &&
          e.body.trim() == event.body.trim());

      if (index != -1) {
        print(
            "🔁 Replacing sending event at index $index by body match: '${event.body}'");
      }
    }

    // Step 3: Replace if matched, insert otherwise
    if (index != -1) {
      clonedEvents[index] = event;
    } else {
      final isDuplicate = clonedEvents.any((e) => e.eventId == event.eventId);
      if (!isDuplicate) {
        print("➕ Inserting new event: ${event.eventId} '${event.body}'");
        clonedEvents.insert(0, event);
      } else {
        print("⚠️ Skipping duplicate insert for: ${event.eventId}");
      }
    }

    final updatedRoom = ChatRoom(
      id: stored.id,
      tileDetails: stored.tileDetails,
      room: stored.room,
      members: stored.members,
      events: clonedEvents,
    );

    store.addOrUpdateRoom(updatedRoom);

    print("📤 Store write check:");
    for (var e in clonedEvents) {
      print("📤 Final state: ${e.body} - ${e.status}");
    }
  }
}

// Internal wrapper to track event-room pairs in the queue
class _QueuedEvent {
  final Event event;
  final Room room;

  _QueuedEvent(this.event, this.room);
}
