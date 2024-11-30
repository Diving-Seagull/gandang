import 'package:gandang/data/model/path_dto.dart';

class RoutesDto {
  final double total_distance;
  final bool has_tourspot;
  final List<PathDto> path;

  RoutesDto({required this.total_distance, required this.has_tourspot, required this.path});

  Map<String, dynamic> toJson(){
    return {
      'total_distance': total_distance,
      'has_tourspot': has_tourspot,
      'path': path
    };
  }

  factory RoutesDto.fromJson(Map<String, dynamic> json){
    return RoutesDto(
        total_distance: json['total_distance'],
        has_tourspot: json['has_tourspot'],
        path: json['path']
    );
  }
}