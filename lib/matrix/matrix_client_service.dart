import 'package:matrix/matrix.dart';
import 'package:zenify_chat/matrix/handler_service.dart';
import 'package:zenify_chat/models/chat_room_tile.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'package:zenify_chat/services/auth_service.dart';
import 'package:zenify_chat/store/store_service.dart';

class MatrixClientService {
  static final MatrixClientService _instance = MatrixClientService._internal();
  factory MatrixClientService() => _instance;
  MatrixClientService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  late final Client client;
  final StoreService store = StoreService(); // 👈 Made final, owned here
  late final MatrixEventHandlersService eventHandlers;
  final Map<String, Timeline> _roomTimelines = {}; // 👈 Add this
  Timeline? getTimelineForRoom(String roomId) => _roomTimelines[roomId];

  Future<bool> init() async {
    print("🕓 Initializing MatrixClientService $_initialized");
    if (_initialized) return true;
    _initialized = true;

    final creds = await AuthService.getStoredCredentials();
    if (_hasMissingCreds(creds)) {
      print("❌ Missing stored credentials");
      return false;
    }

    await _initializeClient(creds);

    await _initializeRoomData();
    _startEventListeners();

    return true;
  }

  bool _hasMissingCreds(Map<String, String?> creds) {
    return [
      creds['access_token'],
      creds['user_id'],
      creds['device_id'],
      creds['homeserver'],
    ].contains(null);
  }

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

  Future<void> _initializeRoomData() async {
    final rooms = List<Room>.from(client.rooms);
    final List<ChatRoom> chatrooms = [];

    for (final room in rooms) {
      try {
        ChatRoom chatroom = await _initializeChatRoom(room);
        chatrooms.add(chatroom);
        print("🕓 Timeline initialized for ${room.id}");
      } catch (e) {
        print("⚠️ Error loading timeline for ${room.id}: $e");
      }
    }
    store.setRooms(chatrooms);
  }

  Future<ChatRoom> initializeChatRoom(Room room,
      {void Function()? onUpdate}) async {
    return _initializeChatRoom(room, onUpdate: onUpdate);
  }

  Future<ChatRoom> _initializeChatRoom(Room room,
      {void Function()? onUpdate}) async {
    final timeline = await room.getTimeline(onUpdate: onUpdate);

    // Ensure we don’t wait for live sync
    timeline.allowNewEvent = false;
    await timeline.getRoomEvents(
      direction: Direction.b,
      historyCount: 15,
      filter: StateFilter(types: [EventTypes.Message]),
    );
    print("📥 Timeline total after initial fetch: ${timeline.events.length}");
    print("📥 Initial prev_batch: ${room.prev_batch}");

    for (final e in timeline.events) {
      print("🧠 Event type: ${e.type}, body: [${e.body}], status: ${e.status}");
    }
    _roomTimelines[room.id] = timeline; // 👈 Save for reuse

    final filteredEvents = timeline.events
        .where((e) => e.type == EventTypes.Message && e.body.trim().isNotEmpty)
        .toList()
      ..sort((a, b) =>
          b.originServerTs.compareTo(a.originServerTs)); // ✅ newest to oldest

    print("🕓 Final loaded events: ${filteredEvents.length}");

    final tile = ChatRoomTile(
      id: room.id,
      displayName: room.name,
      lastMessage: filteredEvents.firstOrNull?.body,
    );

    return ChatRoom(
      id: room.id,
      room: room,
      events: filteredEvents,
      tileDetails: tile,
    );
  }

  void _startEventListeners() {
    eventHandlers = MatrixEventHandlersService(
      client: client,
      store: store,
    );
    eventHandlers.init();
  }
}
