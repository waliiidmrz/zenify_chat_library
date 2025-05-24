/// 🧑‍🦱 Extracts the first uppercase letter from a Matrix ID for avatar purposes
String getAvatarLetter(String matrixId) {
  try {
    return matrixId
        .replaceAll("@", "")
        .split(":")
        .first
        .substring(0, 1)
        .toUpperCase();
  } catch (_) {
    return "?";
  }
}

/// 🙋 Checks if the sender is the current user
bool isMe(String myId, String senderId) {
  return myId == senderId;
}
