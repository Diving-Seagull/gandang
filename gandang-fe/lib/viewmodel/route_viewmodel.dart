import 'package:gandang/data/login/route_datasource.dart';
import 'package:gandang/data/model/route_req.dart';
import 'package:gandang/data/model/routes_dto.dart';
import 'package:gandang/data/model/token_dto.dart';
import 'package:gandang/data/repository/route_repository.dart';

import '../data/global/rest_api_session.dart';

class RouteViewModel {
  final RouteRepository repository = RouteRepository(RouteDataSource('http://${RestApiSession.IP_PATH}:8080/api'));

  Future<RoutesDto?> postRoutes(RouteReq req, TokenDto tokenDto) async {
    try{
      var routePoints = await repository.postRoutes(req, tokenDto);
      return routePoints;
    }catch(e) {
      throw Exception('Failed to postRoutes $e');
    }
  }
}