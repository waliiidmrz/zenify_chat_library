import 'package:matrix/matrix.dart';
import 'package:zenify_chat/matrix/handler_service.dart';
import 'package:zenify_chat/models/chat_room_tile.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/store/notification_service.dart';
import 'package:zenify_chat/utils/preview_event_types.dart';

/// 🔹 Singleton class that manages Matrix SDK client and room/timeline state.
class MatrixClientService {
  static final MatrixClientService _instance = MatrixClientService._internal();
  factory MatrixClientService() => _instance;
  MatrixClientService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  late final Client client;
  final store = MockStoreService();
  late final NotificationService notificationService =
      NotificationService(store: store);
  late final MatrixEventHandlersService eventHandlers;
  static const bool useMockMode = true;

  /// In-memory map of roomId → timeline for quick access.
  final Map<String, Timeline> _roomTimelines = {};
  Timeline? getTimelineForRoom(String roomId) => _roomTimelines[roomId];

  /// 🚀 Initializes the Matrix client, loads room data and starts event listeners.
  Future<bool> init() async {
    if (_initialized) return true;
    _initialized = true;
    return true;
  }

  /// 🔐 Check if any of the required stored credentials are missing.
  bool _hasMissingCreds(Map<String, String?> creds) {
    return [
      creds['access_token'],
      creds['user_id'],
      creds['device_id'],
      creds['homeserver'],
    ].contains(null);
  }

  /// 🧠 Initializes the Matrix Client using stored login credentials.
  Future<void> _initializeClient(Map<String, String?> creds) async {
    client = Client('zenify_${creds['user_id']}_${creds['device_id']}');
    client.homeserver = Uri.parse(creds['homeserver']!);

    await client.init(
      newToken: creds['access_token'],
      newUserID: creds['user_id'],
      newDeviceID: creds['device_id'],
      newHomeserver: Uri.parse(creds['homeserver']!),
      newDeviceName: 'Zenify Mobile',
      waitForFirstSync: true,
    );
  }

  /// 🗃 Loads all room data and initializes their timelines.
  Future<void> _initializeRoomData() async {
    final rooms = List<Room>.from(client.rooms);
    final List<ChatRoom> chatrooms = [];

    for (final room in rooms) {
      try {
        final chatroom = await _initializeChatRoom(room);
        chatrooms.add(chatroom);
      } catch (e) {
        print("⚠️ Error loading timeline for ${room.id}: $e");
      }
    }

    // 🏪 Save to global store
    store.setRooms(chatrooms);
  }

  /// Public wrapper for initializing a room externally (e.g., after joining).
  Future<ChatRoom> initializeChatRoom(Room room, {void Function()? onUpdate}) {
    return _initializeChatRoom(room, onUpdate: onUpdate);
  }

  /// 📜 Initializes timeline + metadata for a given room.
  Future<ChatRoom> _initializeChatRoom(Room room,
      {void Function()? onUpdate}) async {
    final timeline = await room.getTimeline(onUpdate: onUpdate);
    timeline.allowNewEvent = false; // Only load history, not real-time

    await timeline.getRoomEvents(
      direction: Direction.b,
      historyCount: 30,
      filter: StateFilter(types: [EventTypes.Message, EventTypes.Reaction]),
    );

    _roomTimelines[room.id] = timeline;
    final reactions =
        timeline.events.where((e) => e.type == EventTypes.Reaction);
    final reactionMap =
        <String, Map<String, String>>{}; // eventId → sender → emoji
    for (final reaction in reactions) {
      final relatesTo = reaction.content['m.relates_to'];
      if (relatesTo is! Map<String, dynamic>) continue;
      if (relatesTo['rel_type'] != 'm.annotation') continue;

      final targetId = relatesTo['event_id'];
      final emoji = relatesTo['key'];
      final sender = reaction.senderId;

      if (targetId is! String || emoji is! String) continue;

      reactionMap.putIfAbsent(targetId, () => {});
      reactionMap[targetId]![sender] = emoji;
    }
    final filteredEvents = timeline.events
        .where((e) =>
            PreviewEventTypes.allowed.contains(e.type) &&
            e.body.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => b.originServerTs.compareTo(a.originServerTs));

    print("🧭 Sorted filtered events (newest → oldest):");
    for (final e in timeline.events) {
      print(
          "📥 Init event: ${e.eventId} | type=${e.type} | status=${e.status.name} | body='${e.body}'");
    }

    for (int i = 0; i < filteredEvents.length; i++) {
      final e = filteredEvents[i];
      final reactionsForEvent = reactionMap[e.eventId];

      if (reactionsForEvent == null) continue;

      final updated = Event.fromJson(e.toJson(), e.room);

      // Store all reactions in unsigned['reaction'] so your UI can read it
      updated.unsigned?['reaction'] = reactionsForEvent;
      print(
          "➕ Added reactions to ${e.eventId}: $reactionsForEvent"); // 👈 LOG HERE

      filteredEvents[i] = updated;
    }

    final latestMessage = filteredEvents.firstOrNull;
    String? lastMessageBody;

// fallback if no reaction from other user
    print("🧪 Last message debug:");
    print("🔸 eventId: ${latestMessage?.eventId}");
    print("🔸 status: ${latestMessage?.status.name}");
    print("🔸 type: ${latestMessage?.type}");
    print("🔸 msgtype: ${latestMessage?.messageType}");
    print("🔸 body: '${latestMessage?.body}'");
    print("🔸 hasAttachment: ${latestMessage?.hasAttachment}");
    print("🔸 mimeType: ${latestMessage?.attachmentMimetype}");

    lastMessageBody ??= formatLastMessagePreview(latestMessage, client);
    print("🧾 Computed preview: '$lastMessageBody'");

    final receiptState = LatestReceiptState.fromJson(
      room.roomAccountData[LatestReceiptState.eventType]?.content ?? {},
    );
    final latestReceiptEventId = receiptState.global.latestOwnReceipt?.eventId;

    final hasSeen = latestMessage == null ||
        latestMessage.senderId == client.userID ||
        latestMessage.eventId == latestReceiptEventId;
    print("📝 Final lastMessageBody: '$lastMessageBody'");

    print(
        "📦 Restored latestOwnReceipt from roomAccountData: $latestReceiptEventId");
    print(
        "📬 [${room.name}] lastEvent=${latestMessage?.eventId} | seen=$hasSeen");
    print(
        "🔔 Init notificationCount for ${room.name}: ${room.notificationCount}");

    final tile = ChatRoomTile(
      id: room.id,
      displayName: room.name,
      lastMessage: lastMessageBody,
      isLastMessageSeen: hasSeen,
      notificationCount: room.notificationCount,
    );

    return ChatRoom(
      id: room.id,
      room: room,
      events:
          filteredEvents.where((e) => e.type == EventTypes.Message).toList(),
      tileDetails: tile,
    );
  }

  String? formatLastMessagePreview(Event? event, Client client) {
    if (event == null) return null;

    final senderName = event.senderId.split(':').first.split('@').last;
    final isMe = event.senderId == client.userID;

    print("🧠 formatLastMessagePreview called for: ${event.eventId}");
    print("→ msgtype: ${event.messageType}, isMe: $isMe, type=${event.type}");

    // ✅ Special case: Reaction
    if (event.type == EventTypes.Reaction) {
      final relatesTo = event.content['m.relates_to'];
      final emoji = relatesTo is Map ? relatesTo['key'] : null;
      if (emoji is String && emoji.isNotEmpty) {
        return isMe
            ? "You reacted with $emoji"
            : "$senderName reacted with $emoji";
      }
    }

    // ✅ Handle standard message types
    switch (event.messageType) {
      case MessageTypes.Image:
        return isMe ? "You sent an image" : "$senderName sent an image";

      case MessageTypes.Audio:
        return isMe
            ? "You sent a voice message"
            : "$senderName sent a voice message";

      case MessageTypes.Video:
        return isMe ? "You sent a video" : "$senderName sent a video";

      case MessageTypes.File:
        return isMe ? "You sent a file" : "$senderName sent a file";

      case MessageTypes.Sticker:
        return isMe ? "You sent a sticker" : "$senderName sent a sticker";

      default:
        return event.body.trim(); // fallback
    }
  }

  /// 📡 Initializes the event handler service.
  void _startEventListeners() {
    eventHandlers = MatrixEventHandlersService(
      client: client,
      store: store,
    );
    eventHandlers.init();
  }
}
