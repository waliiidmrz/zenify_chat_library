import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> registerUser(String username, String password) async {
  final url = Uri.parse('http://10.0.2.2:3000/register');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    "username": username,
    "password": password,
    "displayname": username,
    "device_id": "FLUTTERDEVICE"
  });

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print("✅ Registered: ${jsonDecode(response.body)['user_id']}");
      return true;
    } else {
      print("❌ Registration failed: ${response.statusCode} - ${response.body}");
      return false;
    }
  } catch (e) {
    print("❌ Exception during registration: $e");
    return false;
  }
}
