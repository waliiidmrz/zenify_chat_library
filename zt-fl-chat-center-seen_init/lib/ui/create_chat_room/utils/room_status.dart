enum RoomStatusType { created, alreadyExists, error }

class RoomStatus {
  final RoomStatusType status;
  final String? roomId;
  final String? message;

  bool get success => status != RoomStatusType.error;
  bool get created => status == RoomStatusType.created;

  RoomStatus._(this.status, this.roomId, this.message);

  factory RoomStatus.success(String roomId, {bool isNew = true}) {
    return RoomStatus._(
      isNew ? RoomStatusType.created : RoomStatusType.alreadyExists,
      roomId,
      null,
    );
  }

  factory RoomStatus.error(String message) {
    return RoomStatus._(RoomStatusType.error, null, message);
  }
}
