import 'dart:convert';
import 'dart:convert' show utf8;
import 'package:http/http.dart' as http;
import '../models/station.dart';
import '../models/sensor_data.dart';
import '../models/historical_data.dart';

class StationService {
  static const String baseUrl = 'https://datamanagerment.anhkiet.xyz';

  // Lấy danh sách tất cả trạm
  Future<List<Station>> getStations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/monitoring_stations/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Đảm bảo encoding UTF-8 khi decode JSON
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(responseBody);
        return jsonData.map((json) => Station.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stations: $e');
      throw Exception('Failed to load stations: $e');
    }
  }

  // Lấy dữ liệu mới nhất của một trạm
  Future<SensorData?> getLatestSensorData(int stationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/raw_sensor_data/latest/station_name/$stationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Đảm bảo encoding UTF-8 khi decode JSON
        final String responseBody = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(responseBody);
        print('API Response for station $stationId: $jsonData');

        // Kiểm tra nếu response có detail rỗng
        if (jsonData is Map &&
            jsonData.containsKey('detail') &&
            jsonData['detail'] == '') {
          print('No sensor data available for station $stationId');
          return null;
        }

        if (jsonData != null && jsonData.isNotEmpty) {
          return SensorData.fromJson(jsonData);
        }
        return null;
      } else {
        print('Failed to load sensor data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
      return null;
    }
  }

  // Lấy dữ liệu mới nhất của tất cả trạm
  Future<Map<int, SensorData?>> getAllLatestSensorData(
    List<Station> stations,
  ) async {
    Map<int, SensorData?> result = {};

    for (Station station in stations) {
      if (station.isActive) {
        try {
          final sensorData = await getLatestSensorData(station.stationId);
          result[station.stationId] = sensorData;
        } catch (e) {
          print('Error fetching data for station ${station.stationId}: $e');
          result[station.stationId] = null;
        }
      }
    }

    return result;
  }

  // Lấy dữ liệu lịch sử của một trạm
  Future<List<HistoricalData>> getHistoricalData(int stationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/historical_wqi_data/by_station_id/$stationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Đảm bảo encoding UTF-8 khi decode JSON
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(responseBody);
        return jsonData.map((json) => HistoricalData.fromJson(json)).toList();
      } else {
        print('Failed to load historical data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching historical data: $e');
      return [];
    }
  }
}
