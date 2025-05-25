import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:zenify_chat/store/mock_store.dart';
import 'package:zenify_chat/ui/create_chat_room/utils/name_validator.dart';
import 'package:zenify_chat/ui/create_chat_room/utils/room_creator.dart';
import 'package:zenify_chat/ui/create_chat_room/utils/room_navigator.dart';
import 'package:zenify_chat/matrix/matrix_client_service.dart';

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("❌ $message")),
  );
}

Future<void> handleRoomCreation({
  required BuildContext context,
  required TextEditingController roomNameController,
  required String inviteeMatrixId,
}) async {
  final roomName = roomNameController.text.trim();

  if (!validateRoomName(context, roomName)) return;

  try {
    final status = await createOrRedirectRoom(roomName, inviteeMatrixId);
    if (!status.success || status.roomId == null) {
      return _showError(context, status.message ?? "Unknown error");
    }

    final roomId = status.roomId!;
    final created = status.created;

    print("✅ Room ID returned: $roomId (created: $created)");

    final matrixClient = MatrixClientService();
    final initialized = await matrixClient.init();
    if (!initialized) return _showError(context, "Failed to initialize Matrix");

    // Ensure the client is aware of the new room
    await matrixClient.client.sync();
    print("🔄 Matrix synced");

    // Re-fetch the room
    Room? room;
    for (int i = 0; i < 5; i++) {
      room = matrixClient.client.getRoomById(roomId);
      print("🔍 Attempt ${i + 1}: found room? ${room != null}");
      if (room != null) break;
      await Future.delayed(Duration(milliseconds: 300 * (i + 1)));
    }

    if (room == null) {
      return _showError(context, "Room not found after creation (sync delay).");
    }

    // Force re-init the chat room to populate store
    final chatRoom = await matrixClient.initializeChatRoom(room);
    matrixClient.store.addOrUpdateRoom(chatRoom);
    print("🧠 ChatRoom initialized and added to store: ${chatRoom.id}");
  final MockStoreService store;

    navigateToRoom(
      context: context,
      room: room,
      store: matrixClient.store,
      created: created,
    );
  } catch (e, stack) {
    print("❌ Unexpected error during room creation: $e");
    print(stack);
    _showError(context, "Unexpected error: $e");
  }
}
