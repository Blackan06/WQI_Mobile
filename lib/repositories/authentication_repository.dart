// lib/repositories/authentication_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthResponse {
  final String accessToken;
  final int account_id;

  AuthResponse({required this.accessToken, required this.account_id});
}

class AuthenticationRepository {
  Future<AuthResponse?> login(String username, String password) async {
    try {
      final url = Uri.parse('https://dm.anhkiet.xyz/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Extract user ID from JWT token
        final token = jsonData['access_token'];
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          return AuthResponse(accessToken: token, account_id: payload['id']);
        }
      }
      return null;
    } catch (e) {
      print('Error in login: $e');
      return null;
    }
  }
}
