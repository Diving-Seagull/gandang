class RoadSearchInfo {
  final String startName;
  final double startX;
  final double startY;
  final String endName;
  final double endX;
  final double endY;

  RoadSearchInfo({required this.startName, required this.startX, required this.startY, required this.endName, required this.endX, required this.endY});

  Map<String, dynamic> toJson(){
    return {
      'startName': startName,
      'startX': startX,
      'startY': startY,
      'endName': endName,
      'endX': endX,
      'endY': endY
    };
  }
}