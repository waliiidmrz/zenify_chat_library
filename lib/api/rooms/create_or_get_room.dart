import 'dart:convert';
import 'package:http/http.dart' as http;

Future<(String?, int?)> createOrGetRoom(
    String accessToken, String roomName, String inviteeMatrixId) async {
  final url = Uri.parse('http://10.0.2.2:3000/rooms/create');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken'
  };
  final body = jsonEncode({"name": roomName, "invitee": inviteeMatrixId});

  try {
    final response = await http.post(url, headers: headers, body: body);
    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 409) {
      final roomId = data['roomId'];
      print(response.statusCode == 201
          ? "✅ Room created: $roomId"
          : "↪️ Room already exists: $roomId");
      return (roomId.toString(), response.statusCode);
    } else {
      throw Exception(
          "Server error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("❌ Network error: $e");
    return (null, null);
  }
}
