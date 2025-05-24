import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matrix/matrix.dart';
import 'package:zenify_chat/matrix/matrix_client_service.dart';
import 'package:zenify_chat/models/message.dart';
import 'package:http/http.dart' as http;
import 'message_reply_preview.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// 💬 Visual container that holds text, timestamp, reactions & status
class MessageContainer extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool isSelected;

  const MessageContainer({
    super.key,
    required this.message,
    required this.isMe,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      stepWidth: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getBubbleColor(),
          borderRadius: _buildRadius(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MessageReplyPreview(content: message.content),
            _buildAttachmentContent(),
            if (message.reactions.isNotEmpty) _buildReactionBar(),
            const SizedBox(height: 6),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// 📎 Renders image/file attachments or fallback text
  Widget _buildAttachmentContent() {
    final event = message.originalEvent;
    final getThumbnail = event?.attachmentMimetype.startsWith('image/');

    if (event == null || !event.hasAttachment) {
      return Text(
        message.content.trim().split('\n').last,
        style: const TextStyle(fontSize: 15),
      );
    }

    return FutureBuilder<Uri?>(
      future: event.getAttachmentUri(getThumbnail: getThumbnail!),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 160,
            width: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final uri = snapshot.data;
        if (uri == null) {
          return const Text(
            "[Could not load attachment]",
            style: TextStyle(color: Colors.red),
          );
        }

        final mime = event.attachmentMimetype;

        if (mime.startsWith("image/")) {
          return FutureBuilder<Uint8List>(
            future: _fetchImageBytes(uri.toString()),
            builder: (context, imgSnapshot) {
              if (!imgSnapshot.hasData) {
                return const SizedBox(
                  height: 160,
                  width: 160,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imgSnapshot.data!,
                  height: 160,
                  width: 160,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        }

        if (mime == "application/pdf") {
          return _buildPdfTile(context, uri.toString(), event.body);
        }

        if (mime.startsWith("video/")) {
          return _buildVideoTile(context, uri.toString(), event.body);
        }

        // Fallback for other file types
        return Row(
          children: [
            const Icon(Icons.insert_drive_file, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message.content,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPdfTile(BuildContext context, String url, String filename) {
    return GestureDetector(
      onTap: () async {
        try {
          final accessToken = MatrixClientService().client.accessToken;
          final response = await http.get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $accessToken'},
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to fetch PDF');
          }

          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/$filename';

          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          await OpenFilex.open(filePath);
        } catch (e) {
          print("❌ Error opening PDF: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to open PDF.")),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(8),
          color: Colors.red.shade50,
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                filename,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoTile(BuildContext context, String url, String filename) {
    return GestureDetector(
      onTap: () async {
        try {
          final accessToken = MatrixClientService().client.accessToken;
          final response = await http.get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $accessToken'},
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to fetch video');
          }

          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/$filename';

          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          await OpenFilex.open(filePath);
        } catch (e) {
          print("❌ Error opening video: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to open video.")),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.shade50,
        ),
        child: Row(
          children: [
            const Icon(Icons.videocam, color: Colors.blue, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                filename,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.play_arrow, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _fetchImageBytes(String url) async {
    final accessToken = MatrixClientService().client.accessToken;
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load image: ${response.statusCode}');
    }

    return response.bodyBytes;
  }

  BorderRadius _buildRadius() {
    return BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(isMe ? 0 : 12),
      bottomRight: Radius.circular(isMe ? 12 : 0),
    );
  }

  Widget _buildFooter() {
    final time = DateFormat.Hm().format(
      DateTime.fromMillisecondsSinceEpoch(message.timestamp ?? 0),
    );

    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 6),
          _buildStatusIcon(message.status),
        ],
      ),
    );
  }

  Widget _buildReactionBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 4,
        children: message.reactions.map((emoji) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getBubbleColor() {
    if (isSelected) return Colors.blue.shade100;
    if (message.status == EventStatus.sending) return Colors.orange.shade100;
    if (message.status == EventStatus.sent) return Colors.grey.shade200;
    if (message.status == EventStatus.synced) {
      return isMe ? const Color(0xFFDCF8C6) : Colors.white;
    }
    return isMe ? const Color(0xFFDCF8C6) : Colors.white;
  }

  Widget _buildStatusIcon(EventStatus? status) {
    if (message.isSeenByOtherUser) {
      return const Icon(Icons.remove_red_eye, size: 12, color: Colors.blue);
    }

    switch (status) {
      case EventStatus.sending:
        return const Icon(Icons.access_time, size: 12, color: Colors.orange);
      case EventStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.grey);
      case EventStatus.synced:
        return const Icon(Icons.done_all, size: 12, color: Colors.green);
      default:
        return const SizedBox.shrink();
    }
  }
}
