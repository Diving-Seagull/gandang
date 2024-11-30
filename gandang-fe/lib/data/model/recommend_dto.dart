class RecommendDto {
  final String end_address;
  final double end_latitude;
  final double end_longitude;
  final int visit_count;
  final DateTime last_visited_at;
  final double distance;


  Map<String, dynamic> toJson(){
    return {
      "end_latitude": end_latitude,
      "end_longitude": end_longitude,
      "end_address": end_address,
      "visit_count":  visit_count,
      "last_visited_at": last_visited_at,
      "distance": distance,
    };
  }

  factory RecommendDto.fromJson(Map<String, dynamic> json){
    return RecommendDto(
        end_address : json['end_address'],
        end_latitude:  json['end_latitude'],
        end_longitude:  json['end_longitude'],
        visit_count:  json['visit_count'],
        last_visited_at:  DateTime.parse(json['last_visited_at']),
        distance: json['distance'],
    );
  }

  RecommendDto({required this.end_address, required this.end_latitude, required this.end_longitude, required this.visit_count, required this.last_visited_at, required this.distance});
}