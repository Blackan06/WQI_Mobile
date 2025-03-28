import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

// Màn hình Giám sát chất lượng nước
class WaterQualityScreen extends StatefulWidget {
  @override
  _WaterQualityScreenState createState() => _WaterQualityScreenState();
}

class _WaterQualityScreenState extends State<WaterQualityScreen> {
  Map<String, dynamic>? _latestData;
  bool _isLoading = false;

  // Hàm tính WQI (Water Quality Index)
  double calculateWQI(double pH, double temperature) {
    return (pH * temperature) / 10;
  }

  // Hàm lấy dữ liệu từ API
  Future<void> fetchLatestData() async {
    setState(() {
      _isLoading = true;
    });

    String dateFilter = DateTime.now().toIso8601String().substring(0, 10);
    String url =
        "https://wise-bird-still.ngrok-free.app/api/ph/logs?date_filter=$dateFilter&pond_id=1&utm_source=zalo&utm_medium=zalo&utm_campaign=zalo";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          var latest = data.last;
          double pH = latest['ph_value'];
          double temperature = latest['temperature'];
          double wqi = calculateWQI(pH, temperature);

          setState(() {
            _latestData = {
              'ph': pH,
              'temperature': temperature,
              'wqi': wqi,
              'measurement_time': latest['measurement_time'],
            };
          });
        } else {
          setState(() {
            _latestData = null;
          });
        }
      } else {
        print("Lỗi khi gọi API: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLatestData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Đặt nền của toàn màn hình là đen
      appBar: AppBar(
        title: Text(
          'Giám sát chất lượng nước',
          style: TextStyle(color: Colors.blueAccent),
        ),
        backgroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _latestData == null
              ? Center(
                child: Text(
                  'Không có dữ liệu',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDataCard(
                      'pH',
                      _latestData!['ph'].toStringAsFixed(2),
                      Colors.blueAccent,
                    ),
                    _buildDataCard(
                      'Temperature',
                      _latestData!['temperature'].toStringAsFixed(2),
                      Colors.orange,
                    ),
                    _buildDataCard(
                      'WQI',
                      _latestData!['wqi'].toStringAsFixed(2),
                      Colors.green,
                    ),
                    _buildDataCard(
                      'Time',
                      _latestData!['measurement_time'].toString(),
                      Colors.purple,
                    ),
                  ],
                ),
              ),
    );
  }

  // Widget xây dựng ô vuông hiển thị dữ liệu
  Widget _buildDataCard(String title, String value, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color,
          width: 2,
        ), // Đặt màu khung là màu xanh nước biển
      ),
      color: Colors.black.withOpacity(0.7), // Màu nền của Card đen
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent, // Chữ tiêu đề màu xanh nước biển
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey, // Chữ giá trị màu xanh đen
              ),
            ),
          ],
        ),
      ),
    );
  }
}
