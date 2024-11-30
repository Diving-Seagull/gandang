import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandang/data/model/star_content.dart';
import 'package:gandang/data/model/token_dto.dart';
import '../global/rest_api_session.dart';
import '../login/star_datasource.dart';
import '../repository/star_repository.dart';

class StarParams {
  final TokenDto tokenDto;

  StarParams(this.tokenDto);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StarParams && other.tokenDto == tokenDto;
  }

  @override
  int get hashCode => tokenDto.hashCode;
}

const String url = 'http://${RestApiSession.IP_PATH}:8080/api';

// 데이터 소스 Provider
final starDataSourceProvider = Provider<StarDataSource>((ref) {
  return StarDataSource(url);
});

// Repository Provider
final starRepositoryProvider = Provider<StarRepository>((ref) {
  final dataSource = ref.watch(starDataSourceProvider);
  return StarRepository(dataSource);
});