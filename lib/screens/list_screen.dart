import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart'; // Đảm bảo import đúng file chứa WaterQualityScreen

class MonitoringListScreen extends StatefulWidget {
  @override
  _MonitoringListScreenState createState() => _MonitoringListScreenState();
}

class _MonitoringListScreenState extends State<MonitoringListScreen> {
  List<dynamic> _allData = [];
  bool _isLoading = false;

  // Hàm lấy tất cả dữ liệu giám sát từ API
  Future<void> fetchAllData() async {
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
        setState(() {
          _allData = data;
        });
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
    fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Danh sách giám sát',
          style: TextStyle(color: Colors.blueAccent),
        ),
        backgroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _allData.length,
                itemBuilder: (context, index) {
                  var item = _allData[index];
                  return Card(
                    color: Colors.black.withOpacity(0.7),
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        'pH: ${item['ph_value']} | Temp: ${item['temperature']}',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Time: ${item['measurement_time']}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
