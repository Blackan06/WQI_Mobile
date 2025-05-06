import 'dart:convert';
import 'dart:math'; // Thêm import Random
import 'dart:async'; // Thêm import Timer
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'login_screen.dart';
import '../main.dart';

// Màn hình Giám sát chất lượng nước
class WaterQualityScreen extends StatefulWidget {
  @override
  _WaterQualityScreenState createState() => _WaterQualityScreenState();
}

class _WaterQualityScreenState extends State<WaterQualityScreen> {
  Map<String, dynamic>? _latestData;
  bool _isLoading = false;
  final Random _random = Random();
  Timer? _timer; // Timer để tự động cập nhật

  // Hàm tạo dữ liệu random
  Map<String, dynamic> _generateRandomData() {
    double ph = 6.0 + _random.nextDouble() * 3.0; // pH từ 6.0-9.0
    double temp = 25.0 + _random.nextDouble() * 5.0; // nhiệt độ từ 25-30°C
    double wqi = calculateWQI(ph, temp);

    return {
      'ph': ph,
      'temperature': temp,
      'wqi': wqi,
      'measurement_time': DateTime.now().toString(),
    };
  }

  // Hàm tính WQI (Water Quality Index)
  double calculateWQI(double pH, double temperature) {
    return (pH * temperature) / 10;
  }

  // Hàm lấy dữ liệu từ API
  Future<void> fetchLatestData() async {
    if (_isLoading) return; // Tránh gọi API nhiều lần khi đang loading

    setState(() {
      _isLoading = true;
    });

    // Tạo dữ liệu random ngay lập tức
    setState(() {
      _latestData = _generateRandomData();
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchLatestData();
    // Khởi tạo timer để tự động cập nhật mỗi 5 giây
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchLatestData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy timer khi widget bị dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Giám sát chất lượng nước',
          style: TextStyle(color: Colors.blueAccent),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.blueAccent),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MyApp()),
              );
            },
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isLoading = true;
          });
          await fetchLatestData();
        },
        child:
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
