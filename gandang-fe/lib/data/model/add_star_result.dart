class AddStarResult {
  final int route_id;
  final int star_id;
  final DateTime starred_at;

  AddStarResult(this.route_id, this.star_id, this.starred_at);

  Map<String, dynamic> toJson(){
    return {
      "route_id": route_id,
      "star_id": star_id,
      "starred_at": starred_at,
    };
  }

  factory AddStarResult.fromJson(Map<String, dynamic> json){
    return AddStarResult(
        json['route_id'],
        json['star_id'],
        DateTime.parse(json['starred_at'])
    );
  }
}