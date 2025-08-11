import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/station.dart';
import '../models/historical_data.dart';
import '../services/station_service.dart';

class MonitoringListScreen extends StatefulWidget {
  @override
  _MonitoringListScreenState createState() => _MonitoringListScreenState();
}

class _MonitoringListScreenState extends State<MonitoringListScreen> {
  List<Station> _stations = [];
  List<HistoricalData> _historicalData = [];
  Station? _selectedStation;
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

      setState(() {
        _stations = stations;

        // Mặc định chọn trạm đầu tiên nếu chưa có trạm nào được chọn
        if (_selectedStation == null && stations.isNotEmpty) {
          _selectedStation = stations.first;
        }

        _isLoading = false;
      });

      // Lấy dữ liệu lịch sử cho trạm được chọn
      if (_selectedStation != null) {
        await fetchHistoricalData(_selectedStation!.stationId);
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm lấy dữ liệu lịch sử
  Future<void> fetchHistoricalData(int stationId) async {
    try {
      final historicalData = await _stationService.getHistoricalData(stationId);
      setState(() {
        _historicalData = historicalData;
      });
    } catch (e) {
      print('Error fetching historical data: $e');
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
          'Dữ liệu lịch sử',
          style: TextStyle(color: Colors.blueAccent),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blueAccent),
            onPressed: fetchData,
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
                    // Historical data list
                    if (_selectedStation != null)
                      Expanded(child: _buildHistoricalDataList()),
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
                    });
                    fetchHistoricalData(station.stationId);
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

  // Widget hiển thị danh sách dữ liệu lịch sử
  Widget _buildHistoricalDataList() {
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

          // Dữ liệu lịch sử
          if (_historicalData.isNotEmpty) ...[
            Expanded(
              child: ListView.builder(
                itemCount: _historicalData.length,
                itemBuilder: (context, index) {
                  final data = _historicalData[index];
                  return _buildHistoricalDataCard(data);
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[600]),
                    SizedBox(height: 16),
                    Text(
                      'Không có dữ liệu lịch sử',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
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

  // Widget hiển thị card dữ liệu lịch sử
  Widget _buildHistoricalDataCard(HistoricalData data) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: Colors.black.withOpacity(0.7),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ngày: ${data.measurementDate}',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getWQIColor(data.wqi),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'WQI: ${data.wqi.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDataItem(
                    'pH',
                    data.ph.toStringAsFixed(2),
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildDataItem(
                    'Nhiệt độ',
                    '${data.temperature.toStringAsFixed(1)}°C',
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildDataItem(
                    'DO',
                    '${data.dissolvedOxygen.toStringAsFixed(2)} mg/L',
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị item dữ liệu
  Widget _buildDataItem(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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

  // Hàm xác định màu WQI
  Color _getWQIColor(double wqi) {
    if (wqi >= 90) return Colors.green;
    if (wqi >= 70) return Colors.yellow;
    if (wqi >= 50) return Colors.orange;
    return Colors.red;
  }
}
