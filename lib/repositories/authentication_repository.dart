// lib/repositories/authentication_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthenticationRepository {
  // Hàm đăng nhập cơ bản
  Future<int?> login(String username, String password) async {
    try {
      final url = Uri.parse('https://dm.anhkiet.xyz/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final userId = jsonData['user']['id'];

        // Trả về userId cho caller
        return userId;
      } else {
        return null;
      }
    } catch (e) {
      print('Error in login: $e');
      return null;
    }
  }
}
