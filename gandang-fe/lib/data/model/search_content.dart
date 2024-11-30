class SearchContent {
  final int id;
  final double start_latitude;
  final double start_longitude;
  final String start_address;
  final double end_latitude;
  final double end_longitude;
  final String end_address;
  final double distance;
  final DateTime created_at;
  final bool starred;

  SearchContent(this.id, this.start_latitude, this.start_longitude,
      this.start_address, this.end_latitude, this.end_longitude,
      this.end_address, this.distance, this.created_at, this.starred);

  Map<String, dynamic> toJson(){
    return {
      "id": id,
      "start_latitude": start_latitude,
      "start_longitude": start_longitude,
      "start_address": start_address,
      "end_latitude": end_latitude,
      "end_longitude": end_longitude,
      "end_address": end_address,
      "distance":  distance,
      "created_at": created_at,
      "starred": starred
    };
  }

  factory SearchContent.fromJson(Map<String, dynamic> json){
    return SearchContent(
        json['id'],
        json['start_latitude'],
        json['start_longitude'],
        json['start_address'],
        json['end_latitude'],
        json['end_longitude'],
        json['end_address'],
        json['distance'],
        DateTime.parse(json['created_at']),
        json['starred']
    );
  }
}