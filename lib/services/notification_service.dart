import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationService {
  static const String baseUrl = 'https://dm.anhkiet.xyz';

  Future<List<NotificationModel>> getNotifications(int accountId) async {
    try {
      final url = '$baseUrl/notifications/notifications/$accountId';
      print('Calling notification API: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      print('Notification API Response Status: ${response.statusCode}');
      print('Notification API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> notificationsJson = data['notifications'];

        return notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to load notifications: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in getNotifications: $e');
      throw Exception('Error fetching notifications: $e');
    }
  }
}
