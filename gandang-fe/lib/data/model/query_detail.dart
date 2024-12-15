class QueryDetail {
  final String address_name;
  final double x;
  final double y;

  QueryDetail(this.address_name, this.x, this.y);

  Map<String, dynamic> toJson(){
    return {
      'address_name': address_name,
      'x': x,
      'y': y
    };
  }

  factory QueryDetail.fromJson(Map<String, dynamic> json){
    return QueryDetail(
        json['address_name'],
        double.parse(json['x']),
        double.parse(json['y'])
    );
  }
}