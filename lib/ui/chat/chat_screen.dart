import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:zenify_chat/matrix/matrix_client_service.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'package:zenify_chat/store/store_service.dart';
import 'package:zenify_chat/ui/chat/widgets/chat_app_bar.dart';
import 'package:zenify_chat/ui/chat/widgets/message_input.dart';
import 'package:zenify_chat/ui/chat/widgets/message_list.dart';
import 'package:zenify_chat/ui/chat/utils/chat_pagination_handler.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomid;
  final StoreService store;

  const ChatScreen({
    super.key,
    required this.chatRoomid,
    required this.store,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ScrollController _scrollController;
  late final ValueNotifier<List<Event>> messagesNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;
  late final ChatRoom chatRoom;
  Timeline? _timeline;
  ChatPaginationHandler? _pagination;

  bool _isMoreRecent(Event a, Event b) {
    return a.status.index > b.status.index;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _isLoadingNotifier = ValueNotifier(false);

    chatRoom = widget.store.getRoomById(widget.chatRoomid) ??
        ChatRoom.empty(widget.chatRoomid);
    messagesNotifier = ValueNotifier(List.from(chatRoom.events));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeTimeline();
      _scrollToBottom();
    });

    widget.store.rooms.addListener(() {
      final updatedRoom = widget.store.getRoomById(widget.chatRoomid);
      if (updatedRoom != null) {
        final List<Event> merged = [];

        final Map<String, Event> existingByEventId = {
          for (var e in messagesNotifier.value.where((e) => e.eventId != null))
            e.eventId!: e,
        };
        final Map<String, Event> existingByTxnId = {
          for (var e
              in messagesNotifier.value.where((e) => e.transactionId != null))
            e.transactionId!: e,
        };

        for (final newEvent in updatedRoom.events) {
          final id = newEvent.eventId;
          final txn = newEvent.transactionId;

          final existingEvent =
              (id != null && existingByEventId.containsKey(id))
                  ? existingByEventId[id]
                  : (txn != null && existingByTxnId.containsKey(txn))
                      ? existingByTxnId[txn]
                      : null;

          if (existingEvent == null) {
            merged.add(newEvent);
          } else if (_isMoreRecent(newEvent, existingEvent)) {
            merged.add(newEvent);
          } else {
            merged.add(existingEvent);
          }
        }

        final updatedIds = merged
            .map((e) => e.eventId)
            .whereType<String>()
            .toSet()
          ..addAll(merged.map((e) => e.transactionId).whereType<String>());

        for (final e in messagesNotifier.value) {
          if (!updatedIds.contains(e.eventId) &&
              !updatedIds.contains(e.transactionId)) {
            merged.add(e);
          }
        }

        merged.sort((a, b) => b.originServerTs.compareTo(a.originServerTs));

        print("📊 Updating messagesNotifier with ${merged.length} events");
        for (var e in merged) {
          print(
              "🎨 Rendering ${e.body} | status: ${e.status} | ts=${e.originServerTs}");
        }

        messagesNotifier.value = merged;
      }
    });
  }

  Future<void> _initializeTimeline() async {
    final matrixClient = MatrixClientService();
    _timeline = matrixClient.getTimelineForRoom(chatRoom.id);

    if (_timeline != null) {
      final updatedRoom = widget.store.getRoomById(chatRoom.id);
      if (updatedRoom != null) {
        messagesNotifier.value = List.from(updatedRoom.events);
      }

      _pagination = ChatPaginationHandler(
        scrollController: _scrollController,
        timeline: _timeline!,
        messagesNotifier: messagesNotifier,
      );

      // Sync isLoading with notifier
      _pagination!.isLoading.addListener(() {
        _isLoadingNotifier.value = _pagination!.isLoading.value;
      });
    }

    await matrixClient.initializeChatRoom(
      chatRoom.room!,
      onUpdate: _pagination?.onTimelineUpdate,
    );
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    try {
      print("✉️ Sending message: $content");
      await chatRoom.room?.sendTextEvent(content);
      _scrollToBottom();
      print("🚀 Sent text: $content");
    } catch (e) {
      print("❌ Failed to send message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to send message")),
      );
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messagesNotifier.dispose();
    _pagination?.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(title: chatRoom.tileDetails.displayName),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isLoadingNotifier,
              builder: (context, isLoadingOlder, _) {
                return MessageList(
                  messagesNotifier: messagesNotifier,
                  scrollController: _scrollController,
                  currentUserId: chatRoom.room?.client.userID ?? '',
                  isLoadingOlder: isLoadingOlder,
                  hasReachedStart: _pagination?.hasReachedStart ?? false,
                );
              },
            ),
          ),
          MessageInput(onSend: _sendMessage),
        ],
      ),
    );
  }
}
