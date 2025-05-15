import 'dart:convert';
import 'package:http/http.dart' as http;
Future<Map<String, String>?> loginToBackend(String username, String password) async {
  final url = Uri.parse('http://10.0.2.2:3000/login');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({"username": username, "password": password});

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return {
      "access_token": data['access_token'],
      "user_id": data['user_id'],
      "device_id": data['device_id'],
      "homeserver": 'http://10.0.2.2:8008'
    };
  } else {
    print("❌ Login failed: ${response.statusCode} - ${response.body}");
    return null;
  }
}
