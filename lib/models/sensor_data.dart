class SensorData {
  final int? id;
  final int stationId;
  final String stationName;
  final double? ph;
  final double? temperature;
  final double? dissolvedOxygen;
  final double? conductivity;
  final double? turbidity;
  final double? wqi;
  final String measurementTime;
  final String? createdAt;

  SensorData({
    this.id,
    required this.stationId,
    required this.stationName,
    this.ph,
    this.temperature,
    this.dissolvedOxygen,
    this.conductivity,
    this.turbidity,
    this.wqi,
    required this.measurementTime,
    this.createdAt,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'],
      stationId: json['station_id'] ?? 0,
      stationName: json['station_name'] ?? '',
      ph: json['ph']?.toDouble(),
      temperature: json['temperature']?.toDouble(),
      dissolvedOxygen: json['dissolved_oxygen']?.toDouble(),
      conductivity: json['conductivity']?.toDouble(),
      turbidity: json['turbidity']?.toDouble(),
      wqi: json['wqi']?.toDouble(),
      measurementTime: json['measurement_time'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'station_id': stationId,
      'station_name': stationName,
      'ph': ph,
      'temperature': temperature,
      'dissolved_oxygen': dissolvedOxygen,
      'conductivity': conductivity,
      'turbidity': turbidity,
      'wqi': wqi,
      'measurement_time': measurementTime,
      'created_at': createdAt,
    };
  }
}
