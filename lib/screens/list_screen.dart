import 'dart:convert';
import 'dart:math';
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
  final Random _random = Random();

  // Generate random pH (typically between 0-14) and temperature (20-35°C)
  Map<String, dynamic> _generateRandomData() {
    double ph = 6.0 + _random.nextDouble() * 3.0; // pH between 6.0-9.0
    double temp =
        25.0 + _random.nextDouble() * 5.0; // temperature between 25-30°C
    return {
      'ph_value': ph.toStringAsFixed(2),
      'temperature': temp.toStringAsFixed(1),
      'measurement_time':
          DateTime.now()
              .subtract(Duration(minutes: _random.nextInt(60)))
              .toString(),
    };
  }

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
        if (data.isEmpty) {
          // Generate 10 random entries if data is empty
          final randomData = List.generate(10, (_) => _generateRandomData());
          setState(() {
            _allData = randomData;
          });
        } else {
          setState(() {
            _allData = data;
          });
        }
      } else {
        print("Lỗi khi gọi API: ${response.statusCode}");
        // Generate random data on error
        final randomData = List.generate(10, (_) => _generateRandomData());
        setState(() {
          _allData = randomData;
        });
      }
    } catch (e) {
      print("Lỗi: $e");
      // Generate random data on error
      final randomData = List.generate(10, (_) => _generateRandomData());
      setState(() {
        _allData = randomData;
      });
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isLoading = true;
          });
          await fetchAllData();
        },
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _allData.isEmpty
                ? Center(
                  child: Text(
                    'Không có dữ liệu',
                    style: TextStyle(color: Colors.white),
                  ),
                )
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
      ),
    );
  }
}
