class StationDto {
  final String station_name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance_in_meters;

  StationDto(this.station_name, this.address, this.latitude, this.longitude, this.distance_in_meters);

  Map<String, dynamic> toJson(){
    return {
      'station_name': station_name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance_in_meters': distance_in_meters
    };
  }

  factory StationDto.fromJson(Map<String, dynamic> json){
    return StationDto(
        json['station_name'],
        json['address'],
        json['latitude'],
        json['longitude'],
        json['distance_in_meters']
    );
  }
}