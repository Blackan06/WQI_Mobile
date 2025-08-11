class Station {
  final int stationId;
  final String stationName;
  final String location;
  final double latitude;
  final double longitude;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Station({
    required this.stationId,
    required this.stationName,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      stationId: json['station_id'] ?? 0,
      stationName: json['station_name'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_id': stationId,
      'station_name': stationName,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
