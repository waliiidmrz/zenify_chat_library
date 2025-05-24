import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
 import 'dart:typed_data';
 
/// 📥 Bottom input field for sending messages
class MessageInput extends StatefulWidget {
  final void Function(String content) onSend;
  final void Function(bool isTyping)? onTypingChanged;
  final Future<void> Function(Uint8List fileBytes, String fileName)?
      onFilePicked;

  const MessageInput(
      {super.key,
      required this.onSend,
      required this.onTypingChanged,
      this.onFilePicked});

  @override
  State<MessageInput> createState() => _MessageInputState();

 
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
      widget.onTypingChanged?.call(false);
      FocusScope.of(context).unfocus(); // Dismiss the keyboard
    }
  }
   Future<void> _pickFile() async {
  final result = await FilePicker.platform.pickFiles(withData: true);

  if (result != null && result.files.single.bytes != null) {
    final fileBytes = result.files.single.bytes!;
    final fileName = result.files.single.name;
    await widget.onFilePicked?.call(fileBytes, fileName);
  }
}

  void _handleTyping(String text) {
    widget.onTypingChanged?.call(text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      child: Row(
  children: [
    IconButton(
      icon: const Icon(Icons.attach_file),
      onPressed: _pickFile,
    ),
    Expanded(
      child: TextField(
        controller: _controller,
        onChanged: _handleTyping,
        decoration: const InputDecoration(
          hintText: "Type a message...",
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onSubmitted: (_) => _handleSend(),
      ),
    ),
    const SizedBox(width: 8),
    IconButton(
      icon: const Icon(Icons.send, color: Colors.blueAccent),
      onPressed: _handleSend,
    ),
  ],
)
    );
  }
}
