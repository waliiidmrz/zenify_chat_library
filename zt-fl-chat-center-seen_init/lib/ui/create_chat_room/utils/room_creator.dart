import 'package:zenify_chat/services/auth_service.dart';
import 'package:zenify_chat/services/room_service.dart';
import 'package:zenify_chat/ui/create_chat_room/utils/room_status.dart';

Future<RoomStatus> createOrRedirectRoom(
    String roomName, String inviteeMatrixId) async {
  final creds = await AuthService.getStoredCredentials();
  final accessToken = creds['access_token'];

  if (accessToken == null) return RoomStatus.error("Missing token");

  final roomService = RoomService();
  final (roomId, statusCode) = await roomService.createOrRedirectToRoom(
    accessToken: accessToken,
    name: roomName,
    inviteeMatrixId: inviteeMatrixId,
  );

  if (roomId == null || statusCode == null) {
    return RoomStatus.error("Failed to create room");
  }

  final isNew = statusCode == 201;
  return RoomStatus.success(roomId, isNew: isNew);
}
