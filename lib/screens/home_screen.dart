import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'login_screen.dart';
import '../main.dart';
import '../models/station.dart';
import '../models/sensor_data.dart';
import '../services/station_service.dart';

// Màn hình Giám sát chất lượng nước
class WaterQualityScreen extends StatefulWidget {
  @override
  _WaterQualityScreenState createState() => _WaterQualityScreenState();
}

class _WaterQualityScreenState extends State<WaterQualityScreen> {
  List<Station> _stations = [];
  Map<int, SensorData?> _latestSensorData = {};
  Station? _selectedStation;
  SensorData? _currentStationData;
  bool _isLoading = false;
  Timer? _timer;
  final StationService _stationService = StationService();

  // Hàm lấy dữ liệu từ API
  Future<void> fetchData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy danh sách trạm
      final stations = await _stationService.getStations();

      // Lấy dữ liệu mới nhất cho tất cả trạm
      final sensorData = await _stationService.getAllLatestSensorData(stations);

      setState(() {
        _stations = stations;
        _latestSensorData = sensorData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Đảm bảo encoding UTF-8
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    fetchData();
    // Khởi tạo timer để tự động cập nhật mỗi 30 giây
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
            icon: const Icon(Icons.refresh, color: Colors.blueAccent),
            onPressed: fetchData,
          ),
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
        onRefresh: fetchData,
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _stations.isEmpty
                ? Center(
                  child: Text(
                    'Không có dữ liệu trạm',
                    style: TextStyle(color: Colors.white),
                  ),
                )
                : Column(
                  children: [
                    // Station selector
                    Container(
                      padding: EdgeInsets.all(16),
                      child: _buildStationSelector(),
                    ),
                    // Current station data
                    if (_selectedStation != null)
                      Expanded(child: _buildCurrentStationData()),
                  ],
                ),
      ),
    );
  }

  // Widget chọn trạm
  Widget _buildStationSelector() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn trạm quan trắc:',
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _stations.length,
              itemBuilder: (context, index) {
                final station = _stations[index];
                final isSelected =
                    _selectedStation?.stationId == station.stationId;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStation = station;
                      _currentStationData =
                          _latestSensorData[station.stationId];
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blueAccent : Color(0xFF424242),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? Colors.blueAccent : Color(0xFF757575),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        station.stationName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFFBDBDBD),
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị dữ liệu trạm hiện tại
  Widget _buildCurrentStationData() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header trạm
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedStation!.isActive ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedStation!.stationName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _selectedStation!.location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _selectedStation!.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedStation!.isActive
                        ? 'Hoạt động'
                        : 'Không hoạt động',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Dữ liệu sensor
          if (_currentStationData != null) ...[
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildDataCard(
                  'pH',
                  _currentStationData!.ph?.toStringAsFixed(2) ?? 'N/A',
                  Colors.blue,
                ),
                _buildDataCard(
                  'Nhiệt độ',
                  '${_currentStationData!.temperature?.toStringAsFixed(1) ?? 'N/A'}°C',
                  Colors.orange,
                ),
                _buildDataCard(
                  'DO',
                  '${_currentStationData!.dissolvedOxygen?.toStringAsFixed(2) ?? 'N/A'} mg/L',
                  Colors.green,
                ),
                _buildDataCard(
                  'WQI',
                  _currentStationData!.wqi?.toStringAsFixed(2) ?? 'N/A',
                  Colors.purple,
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Cập nhật: ${_currentStationData!.measurementTime}',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.sensors_off, size: 64, color: Colors.grey[600]),
                    SizedBox(height: 16),
                    Text(
                      'Không có dữ liệu sensor',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Trạm này chưa có dữ liệu sensor mới nhất',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget xây dựng card cho từng trạm
  Widget _buildStationCard(Station station, SensorData? sensorData) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: station.isActive ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      color: Colors.black.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với tên trạm và trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    station.stationName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: station.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    station.isActive ? 'Hoạt động' : 'Không hoạt động',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              station.location,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
            SizedBox(height: 16),

            // Dữ liệu sensor nếu có
            if (sensorData != null) ...[
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5,
                children: [
                  _buildDataCard(
                    'pH',
                    sensorData.ph?.toStringAsFixed(2) ?? 'N/A',
                    Colors.blue,
                  ),
                  _buildDataCard(
                    'Nhiệt độ',
                    '${sensorData.temperature?.toStringAsFixed(1) ?? 'N/A'}°C',
                    Colors.orange,
                  ),
                  _buildDataCard(
                    'DO',
                    '${sensorData.dissolvedOxygen?.toStringAsFixed(2) ?? 'N/A'} mg/L',
                    Colors.green,
                  ),
                  _buildDataCard(
                    'WQI',
                    sensorData.wqi?.toStringAsFixed(2) ?? 'N/A',
                    Colors.purple,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Cập nhật: ${sensorData.measurementTime}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.sensors_off,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Không có dữ liệu sensor',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Trạm này chưa có dữ liệu sensor mới nhất',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget xây dựng ô vuông hiển thị dữ liệu
  Widget _buildDataCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
