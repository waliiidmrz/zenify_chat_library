import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final void Function(String content) onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isRecording = false;
  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      child: Row(
        children: [
          Expanded(
            child: _isRecording
                ? Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.mic, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        const Text(
                          "Recording...",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  )
                : TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _isRecording ? Icons.send : Icons.mic,
              color: _isRecording ? Colors.blueAccent : Colors.grey,
            ),
            onPressed: _isRecording
                ? () {}
                : () {
                    setState(() {
                      _isRecording = true;
                    });
                  },
          ),
          if (!_isRecording) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blueAccent),
              onPressed: _handleSend,
            ),
          ],
        ],
      ),
    );
  }
}
