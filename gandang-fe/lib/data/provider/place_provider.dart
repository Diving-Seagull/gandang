import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandang/data/login/place_datasource.dart';
import 'package:gandang/data/model/query_detail.dart';

import '../repository/place_repository.dart';

// 데이터 소스 Provider
final placeDataSourceProvider = Provider<PlaceDataSource>((ref) {
  return PlaceDataSource();
});

// Repository Provider
final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  final dataSource = ref.watch(placeDataSourceProvider);
  return PlaceRepository(dataSource);
});