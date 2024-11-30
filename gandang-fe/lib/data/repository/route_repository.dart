import 'package:gandang/data/model/add_star_dto.dart';
import 'package:gandang/data/model/recommend_dto.dart';
import 'package:gandang/data/model/search_content.dart';
import 'package:gandang/data/model/search_data.dart';

import '../login/route_datasource.dart';
import '../model/add_star_result.dart';
import '../model/token_dto.dart';

class RouteRepository {
  final RouteDataSource starDataSource;

  RouteRepository(this.starDataSource);

  Future<List<SearchContent>?> getRecentRoutes(TokenDto tokenDto) async {
    try {
      var result = await starDataSource.getRecentRoutes(tokenDto);
      print('starrepository $result');
      return result;
    } catch (e) {
      throw Exception('Failed to fetch users from repository: $e');
    }
  }

  Future<AddStarResult?> postStarRoute(int id, TokenDto tokenDto) async {
    try {
      var result = await starDataSource.postStarRoutes(id, tokenDto);
      print('starrepository $result');
      return result;
    } catch (e) {
      throw Exception('Failed to fetch users from repository: $e');
    }
  }

  Future<List<RecommendDto>?> getRecommendRoutes(String query, TokenDto tokenDto) async {
    try {
      var result = await starDataSource.getRecommendRoutes(query, tokenDto);
      return result;
    } catch (e) {
      throw Exception('Failed to getRecommendRoutes from repository: $e');
    }
  }
}