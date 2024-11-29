// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gandang/data/login/login_datasource.dart';
// import 'package:gandang/data/model/token_dto.dart';
//
// import '../data/model/jwt_data.dart';
// import '../data/repository/login_repository.dart';
//
// class LoginParams {
//   final TokenDto tokenDto;
//   final String type;
//
//   LoginParams(this.tokenDto, this.type);
// }
//
// // API URL을 설정
// const String apiBaseUrl = 'https://jsonplaceholder.typicode.com';
//
// // 데이터 소스 Provider
// final loginDataSourceProvider = Provider<LoginDataSource>((ref) {
//   return LoginDataSource();
// });
//
// // Repository Provider
// final userRepositoryProvider = Provider<LoginRepository>((ref) {
//   final dataSource = ref.watch(loginDataSourceProvider);
//   return LoginRepository(dataSource);
// });
//
// // 사용자 데이터를 비동기로 관리하는 StateNotifier
// final userProvider = FutureProvider.family<JwtData?, LoginParams>((ref, param) async {
//   final repository = ref.watch(userRepositoryProvider);
//   return await repository.setLogin(param.tokenDto, param.type);
// });