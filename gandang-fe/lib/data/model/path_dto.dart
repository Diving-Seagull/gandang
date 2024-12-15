class PathDto {
  final double lat;
  final double lng;
  final String type;
  final String name;

  PathDto({required this.lat, required this.lng, required this.type, required this.name});

  Map<String, dynamic> toJson(){
    return {
      'lat': lat,
      'lng': lng,
      'type': type,
      'name': name
    };
  }

  factory PathDto.fromJson(Map<String, dynamic> json){
    return PathDto(
        lat: json['lat'],
        lng: json['lng'],
        type: json['type'],
        name: json['name']
    );
  }
}