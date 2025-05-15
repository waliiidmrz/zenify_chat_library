import 'dart:convert';
import 'package:http/http.dart' as http;

// Function to fetch all users from ZT-Chat-Manager
Future<List<String>> getAllUsers() async {
  final url = Uri.parse('http://10.0.2.2:3000/users');
  final headers = {'Content-Type': 'application/json'};

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;

      // Correctly map to List<String> and handle dynamic typing
      List<String> usernames = data
          .where((user) => user is Map<String, dynamic> && user['name'] != null)
          .map<String>((user) => user['name'] as String)
          .toList();

      print("✅ Fetched all users: $usernames");
      return usernames;
    } else {
      print(
          "❌ Error fetching users: ${response.statusCode} - ${response.body}");
      return [];
    }
  } catch (e) {
    print("❌ Exception occurred while fetching users: $e");
    return [];
  }
}
