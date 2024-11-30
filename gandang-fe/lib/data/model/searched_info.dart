class SearchedInfo {
  final String? start_text;
  final String start_address;
  final double start_latitude;
  final double start_longitude;
  final String? end_text;
  final String end_address;
  final double end_latitude;
  final double end_longitude;

  SearchedInfo(this.start_address, this.start_latitude, this.start_longitude,
      this.end_address, this.end_latitude, this.end_longitude, [this.start_text, this.end_text]);
}