import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:zenify_chat/models/utils/model_extensions.dart';
import 'package:zenify_chat/ui/chat/utils/event_mapper.dart';
import 'package:zenify_chat/ui/chat/utils/user_utils.dart';
import 'package:zenify_chat/ui/chat/widgets/message_bubble.dart';

/// 📄 Renders the scrollable list of chat messages with pagination indicators
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
  void _showReactionBar(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          children: ['❤️', '👍', '😂', '🔥', '👀'].map((emoji) {
            return GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                final room = event.room;
                final userId = room.client.userID!;
                final existing = event.getReactionFor(userId);

                if (existing == emoji) {
                  // 🚫 Toggle off (not supported yet: requires tracking reactionEventId)
                  return;
                }

                await room.sendReaction(event.eventId, emoji);
              },
              child: Text(emoji, style: TextStyle(fontSize: 30)),
            );
          }).toList(),
        ),
      ),
    );
  }

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
            // ⏳ Show loading spinner
            if (isLoadingOlder &&
                index == totalItems - (hasReachedStart ? 2 : 1)) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 16),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              );
            }

            // 📜 Show "start of conversation"
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
            final message = mapEventToMessage(event);
            final isMe = message.sender == currentUserId;
            final avatarLetter = getAvatarLetter(message.sender);

            return MessageBubble(
              message: message,
              isMe: isMe,
              isSelected: false,
              avatarLetter: avatarLetter,
              onTap: () {},
              onSwipe: () {},
              onLongPress: () {
                _showReactionBar(context, event);
              },
            );
          },
        );
      },
    );
  }
}
