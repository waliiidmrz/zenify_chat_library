import 'package:flutter/material.dart';
import 'package:zenify_chat/models/message.dart';
import 'message_avatar.dart';
import 'message_container.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final bool isSelected;
  final String? avatarLetter;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final VoidCallback onSwipe;
  final VoidCallback? onAddReaction;
  final void Function(String emoji) onReact;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isSelected,
    this.avatarLetter,
    required this.onLongPress,
    required this.onTap,
    required this.onSwipe,
    required this.onReact,
    this.onAddReaction,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _swipeAnimation;
  bool hasSwiped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.12, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _handleSwipe() {
    if (hasSwiped) return;

    _controller.forward().then((_) {
      _controller.reverse();
      widget.onSwipe();
      hasSwiped = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        hasSwiped = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onTap: widget.onTap,
      onHorizontalDragEnd: (_) => _handleSwipe(),
      child: SlideTransition(
        position: _swipeAnimation,
        child: Align(
          alignment: widget.isMe ? Alignment.centerLeft : Alignment.centerRight,
          child: Row(
            mainAxisAlignment:
                widget.isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MessageAvatar(initial: widget.avatarLetter ?? "?"),
              Flexible(
                child: MessageContainer(
                  message: widget.message,
                  isMe: widget.isMe,
                  isSelected: widget.isSelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
