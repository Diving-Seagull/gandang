import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandang/data/model/search_content.dart';
import 'package:gandang/data/model/token_dto.dart';
import '../global/rest_api_session.dart';
import '../login/route_datasource.dart';
import '../repository/route_repository.dart';

class RouteParams {
  final TokenDto tokenDto;

  RouteParams(this.tokenDto);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteParams && other.tokenDto == tokenDto;
  }

  @override
  int get hashCode => tokenDto.hashCode;
}

const String url = 'http://${RestApiSession.IP_PATH}:8080/api';

// 데이터 소스 Provider
final routeDataSourceProvider = Provider<RouteDataSource>((ref) {
  return RouteDataSource(url);
});

// Repository Provider
final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  final dataSource = ref.watch(routeDataSourceProvider);
  return RouteRepository(dataSource);
});