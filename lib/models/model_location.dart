class LocationModel {
  final String name;
  final double longitude;
  final double latitude;

  LocationModel({
    required this.name,
    required this.longitude,
    required this.latitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? 'Unknown',
      longitude: double.tryParse(json['longitude']) ?? 0.0,
      latitude: double.tryParse(json['latitude']) ?? 0.0,
    );
  }
}
