import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zenify_chat/api/auth/login_api.dart';
import 'package:zenify_chat/api/auth/logout_user.dart';
import 'package:zenify_chat/api/auth/register_user.dart';
import 'package:zenify_chat/matrix/matrix_client_service.dart';

class AuthService {
  static final _storage = FlutterSecureStorage();

  static Future<MatrixClientService?> login(
      String username, String password) async {
    final credentials = await loginToBackend(username, password);
    if (credentials == null) return null;

    // Store credentials securely
    for (final entry in credentials.entries) {
      await _storage.write(key: entry.key, value: entry.value);
    }
    await _storage.write(key: "username", value: username);
    await _storage.write(key: "password", value: password);

    final matrix = MatrixClientService();
    final success = await matrix.init();

    return success ? matrix : null;
  }

  static Future<void> logout({String? accessToken}) async {
    if (accessToken != null) {
      await logoutUser(accessToken); // Call backend logout endpoint
    }
    await _storage.deleteAll();
  }

  static Future<Map<String, String?>> getStoredCredentials() async {
    return {
      'access_token': await _storage.read(key: "access_token"),
      'user_id': await _storage.read(key: "user_id"),
      'device_id': await _storage.read(key: "device_id"),
      'homeserver': await _storage.read(key: "homeserver"),
      'username': await _storage.read(key: "username"),
      'password': await _storage.read(key: "password"),
    };
  }

  /// Register new user and save credentials.
  static Future<bool> register(String username, String password) async {
    return await registerUser(username, password);
  }
}
