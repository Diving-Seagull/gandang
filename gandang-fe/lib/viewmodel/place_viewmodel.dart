import 'package:gandang/data/login/place_datasource.dart';
import 'package:gandang/data/model/query_detail.dart';
import 'package:gandang/data/repository/place_repository.dart';

import '../data/model/station_dto.dart';
import '../data/model/token_dto.dart';

class PlaceViewModel {
  final PlaceRepository repository = PlaceRepository(PlaceDataSource());

  Future<QueryDetail?> getLatLngtoQuery(String query) async {
    try {
      var result = await repository.getLatLngtoString(query);
      return result;
    } catch (e) {
      throw Exception('Failed to fetch users from repository: $e');
    }
  }

  Future<StationDto?> getBicycleStation(double lat, double lng, TokenDto tokenDto) async {
    try {
      var result = await repository.getBicycleStation(lat, lng, tokenDto);
      return result;
    } catch (e) {
      throw Exception('Failed to getBicycleStation from repository: $e');
    }
  }

}