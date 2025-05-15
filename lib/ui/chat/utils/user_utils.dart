String getAvatarLetter(String matrixId) {
  return matrixId
      .replaceAll("@", "")
      .split(":")
      .first
      .substring(0, 1)
      .toUpperCase();
}

bool isMe(String myId, String senderId) {
  return myId == senderId;
}
