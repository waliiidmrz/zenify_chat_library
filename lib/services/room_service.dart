import 'package:zenify_chat/api/rooms/create_or_get_room.dart';

class RoomService {
  Future<(String?, int?)> createOrRedirectToRoom({
    required String accessToken,
    required String name,
    required String inviteeMatrixId,
  }) {
    return createOrGetRoom(accessToken, name, inviteeMatrixId);
  }
}
