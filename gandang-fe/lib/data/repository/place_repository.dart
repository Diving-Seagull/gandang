import 'package:gandang/data/login/place_datasource.dart';
import 'package:gandang/data/model/query_detail.dart';
import 'package:gandang/data/model/station_dto.dart';
import 'package:gandang/data/model/token_dto.dart';

class PlaceRepository  {
  final PlaceDataSource placeDataSource;

  PlaceRepository(this.placeDataSource);

  Future<QueryDetail?> getLatLngtoString(String query) async {
    try {
      var result = await placeDataSource.getLatLngtoString(query);
      return result;
    } catch (e) {
      throw Exception('Failed to getLatLngtoString from repository: $e');
    }
  }

  Future<StationDto?> getBicycleStation(double lat, double lng, TokenDto tokenDto) async {
    try {
      var result = await placeDataSource.getBicycleStation(lat, lng, tokenDto);
      return result;
    } catch (e) {
      throw Exception('Failed to getBicycleStation from repository: $e');
    }
  }
}