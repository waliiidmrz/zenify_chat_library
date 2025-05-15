import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:zenify_chat/ui/chat/utils/event_mapper.dart';
import 'package:zenify_chat/ui/chat/widgets/message_bubble.dart';

class MessageList extends StatelessWidget {
  final ValueNotifier<List<Event>> messagesNotifier;
  final ScrollController scrollController;
  final String currentUserId;
  final bool isLoadingOlder;
  final bool hasReachedStart;

  const MessageList({
    super.key,
    required this.messagesNotifier,
    required this.scrollController,
    required this.currentUserId,
    this.isLoadingOlder = false,
    this.hasReachedStart = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Event>>(
      valueListenable: messagesNotifier,
      builder: (context, events, _) {
        final totalItems = events.length +
            (isLoadingOlder ? 1 : 0) +
            (hasReachedStart ? 1 : 0);

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            // ⏳ Loading spinner
            if (isLoadingOlder &&
                index == totalItems - (hasReachedStart ? 2 : 1)) {
              print("⏳ Showing loading spinner at top of chat (index=$index)");
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 16),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              );
            }

            // 📜 Start of conversation
            if (hasReachedStart && index == totalItems - 1) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "📜 Start of conversation",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            final event = events[index];
            print(
                "🎨 Rendering ${event.body} | status: ${event.status} | ts=${event.originServerTs}");

            final message = mapEventToMessage(event);
            final isMe = message.sender == currentUserId;
            final avatarLetter = message.sender
                .replaceAll("@", "")
                .split(":")
                .first
                .substring(0, 1)
                .toUpperCase();

            return MessageBubble(
              message: message,
              isMe: isMe,
              isSelected: false,
              avatarLetter: avatarLetter,
              onTap: () {},
              onSwipe: () {},
              onLongPress: () {},
              onReact: (_) {},
            );
          },
        );
      },
    );
  }
}
