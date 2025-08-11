class HistoricalData {
  final int id;
  final int stationId;
  final String measurementDate;
  final double temperature;
  final double ph;
  final double dissolvedOxygen;
  final double wqi;
  final String stationName;
  final String createdAt;

  HistoricalData({
    required this.id,
    required this.stationId,
    required this.measurementDate,
    required this.temperature,
    required this.ph,
    required this.dissolvedOxygen,
    required this.wqi,
    required this.stationName,
    required this.createdAt,
  });

  factory HistoricalData.fromJson(Map<String, dynamic> json) {
    return HistoricalData(
      id: json['id'] ?? 0,
      stationId: json['station_id'] ?? 0,
      measurementDate: json['measurement_date'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      ph: (json['ph'] ?? 0.0).toDouble(),
      dissolvedOxygen: (json['do'] ?? 0.0).toDouble(),
      wqi: (json['wqi'] ?? 0.0).toDouble(),
      stationName: json['station_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'station_id': stationId,
      'measurement_date': measurementDate,
      'temperature': temperature,
      'ph': ph,
      'do': dissolvedOxygen,
      'wqi': wqi,
      'station_name': stationName,
      'created_at': createdAt,
    };
  }
}
