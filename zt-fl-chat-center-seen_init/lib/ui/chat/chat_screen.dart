// Imports
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:zenify_chat/models/utils/model_extensions.dart';
import 'package:zenify_chat/models/chatroom.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/store/store_service.dart';
import 'package:zenify_chat/ui/chat/utils/event_utils.dart';
import 'package:zenify_chat/ui/chat/widgets/chat_app_bar.dart';
import 'package:zenify_chat/ui/chat/widgets/message_input.dart';
import 'package:zenify_chat/ui/chat/widgets/message_list.dart';
import 'package:zenify_chat/ui/chat/utils/chat_pagination_handler.dart';
import 'package:zenify_chat/ui/chat/utils/receipt_utils.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomid;
  final MockStoreService store;

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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _isLoadingNotifier = ValueNotifier(false);

    chatRoom = widget.store.getRoomById(widget.chatRoomid) ??
        ChatRoomUtils.empty(widget.chatRoomid);
    messagesNotifier = ValueNotifier(List.from(chatRoom.events));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeTimeline();
      _scrollToBottom();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (chatRoom.room != null) {
        await markRoomAsRead(chatRoom.room!);

        final updatedTile = chatRoom.tileDetails.copyWith(
          isLastMessageSeen: true,
          lastMessage: chatRoom.tileDetails.lastMessage,
        );

        final updatedRoom = chatRoom.copyWith(
          tileDetails: updatedTile,
          room: chatRoom.room,
        );

        widget.store.addOrUpdateRoom(updatedRoom);
      }
    });

    widget.store.rooms.addListener(() {
      final updatedRoom = widget.store.getRoomById(widget.chatRoomid);
      if (updatedRoom != null) {
        final merged = mergeAndSortEvents(
          messagesNotifier.value,
          updatedRoom.events,
        );

        messagesNotifier.value = List.from(merged.reversed);
      }
    });
  }

  Future<void> _initializeTimeline() async {
    final thisroom = widget.store.getRoomById(widget.chatRoomid);

    _timeline = await thisroom?.room?.getTimeline(onUpdate: () {
      _pagination?.onTimelineUpdate();
    });
    if (_timeline == null) {
      print("⚠️ No timeline found for room ${chatRoom.id}");
      return;
    }

    // Use latest events from the store
    final updatedRoom = widget.store.getRoomById(chatRoom.id);
    if (updatedRoom != null) {
      messagesNotifier.value = List.from(updatedRoom.events.reversed);
    }

    _pagination = ChatPaginationHandler(
      scrollController: _scrollController,
      timeline: _timeline!,
      messagesNotifier: messagesNotifier,
      store: widget.store, // ✅ Pass store reference
    );

    // Sync isLoading state with notifier
    _pagination!.isLoading.addListener(() {
      _isLoadingNotifier.value = _pagination!.isLoading.value;
    });
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

  void _handleTypingChanged(bool isTyping) {
    print("⌨️ Typing state changed: $isTyping");

    chatRoom.room?.setTyping(isTyping, timeout: 5000).then((_) {
      print("✅ setTyping($isTyping) sent to server");
    }).catchError((e) {
      print("❌ Failed to send typing event: $e");
    });
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
    final typingUsers = chatRoom.room?.typingUsers ?? [];
    if (typingUsers.isNotEmpty) {
      print("👀 Detected typing users: ${typingUsers.map((u) => u.id)}");
    }
    return Scaffold(
      appBar: ChatAppBar(
        title: chatRoom.tileDetails.displayName,
        store: widget.store,
        roomId: widget.chatRoomid,
      ),
      body: Column(
        children: [
          // 👇 Typing Indicator Widget
          if (typingUsers.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
              child: Text(
                "${typingUsers.map((u) => u.calcDisplayname()).join(', ')} is typing...",
                style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ),

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

          MessageInput(
            onSend: _sendMessage,
            onTypingChanged: _handleTypingChanged,
            onFilePicked: (fileBytes, fileName) async {
              final room = chatRoom.room;

              final file = MatrixFile.fromMimeType(
                bytes: fileBytes,
                name: fileName,
              );
              print("🚀 Sending image: $fileName");
              print("🧾 MIME: ${file.mimeType}");
              print("📦 Size: ${file.size} bytes");
              await room?.sendFileEvent(file);
            },
          ),
        ],
      ),
    );
  }
}
