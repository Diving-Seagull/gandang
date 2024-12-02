import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:gandang/data/login/place_datasource.dart';
import 'package:gandang/data/model/query_detail.dart';
import 'package:gandang/data/model/road_search_info.dart';
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

  Future<List<NLatLng>> getWalkingRoute(RoadSearchInfo searchInfo) async {
    try{
      var routePoints = await placeDataSource.getWalkingRoute(searchInfo);
      return routePoints;
    }catch(e) {
      throw Exception('Failed to road route $e');
    }
  }

  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try{
      var routePoints = await placeDataSource.getAddressFromCoordinates(latitude, longitude);
      return routePoints;
    }catch(e) {
      throw Exception('Failed to road route $e');
    }
  }
}