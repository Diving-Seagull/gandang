import 'package:gandang/data/model/add_star_dto.dart';
import 'package:gandang/data/model/star_content.dart';
import 'package:gandang/data/model/star_data.dart';

import '../login/star_datasource.dart';
import '../model/add_star_result.dart';
import '../model/token_dto.dart';

class StarRepository {
  final StarDataSource starDataSource;

  StarRepository(this.starDataSource);

  Future<List<StarContent>?> getStarRoutes(TokenDto tokenDto) async {
    try {
      var result = await starDataSource.getStarRoutes(tokenDto);
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
}