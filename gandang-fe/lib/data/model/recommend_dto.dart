class RecommendDto {
  final double end_latitude;
  final double end_longitude;
  final String end_address;
  final int visit_count;
  final DateTime last_visited_at;


  Map<String, dynamic> toJson(){
    return {
      "end_latitude": end_latitude,
      "end_longitude": end_longitude,
      "end_address": end_address,
      "visit_count":  visit_count,
      "last_visited_at": last_visited_at,
    };
  }

  factory RecommendDto.fromJson(Map<String, dynamic> json){
    return RecommendDto(
        json['end_latitude'],
        json['end_longitude'],
        json['end_address'],
        json['visit_count'],
        DateTime.parse(json['last_visited_at']),
    );
  }

  RecommendDto(this.end_latitude, this.end_longitude, this.end_address, this.visit_count, this.last_visited_at);
}