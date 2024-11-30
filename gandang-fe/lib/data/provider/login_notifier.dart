import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandang/data/model/token_dto.dart';
import 'package:gandang/data/repository/login_repository.dart';

import '../login/login_datasource.dart';
import '../model/jwt_data.dart';

class LoginNotifier extends StateNotifier<AsyncValue<JwtData?>> {
  final LoginRepository repository;

  LoginNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> setLogin(TokenDto tokenDto, String type) async {
    state = const AsyncValue.loading();
    try {
      final data = await repository.setLogin(tokenDto, type);
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class LoginParams {
  final TokenDto tokenDto;
  final String type;

  LoginParams(this.tokenDto, this.type);
}

// 데이터 소스 Provider
final loginDataSourceProvider = Provider<LoginDataSource>((ref) {
  return LoginDataSource();
});

// Repository Provider
final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  final dataSource = ref.watch(loginDataSourceProvider);
  return LoginRepository(dataSource);
});


final loginProvider = StateNotifierProvider<LoginNotifier, AsyncValue<JwtData?>>((ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return LoginNotifier(repository);
});