import 'package:http/http.dart' as http;

Future<void> logoutUser(String accessToken) async {
  final url = Uri.parse('http://10.0.2.2:3000/logout');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  final response = await http.post(url, headers: headers);

  if (response.statusCode == 200) {
    print("✅ Logged out successfully!");
  } else {
    print("❌ Logout failed: ${response.statusCode} - ${response.body}");
  }
}
