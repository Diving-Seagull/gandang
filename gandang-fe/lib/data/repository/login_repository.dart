import 'package:gandang/data/login/login_datasource.dart';

import '../model/jwt_data.dart';
import '../model/token_dto.dart';

class LoginRepository {
  final LoginDataSource loginDataSource;

  LoginRepository(this.loginDataSource);

  Future<JwtData?> setLogin(TokenDto tokenDto, String type) async {
    try {
      var result = await loginDataSource.postTokenInfo(tokenDto, type);
      print(result);
      return result;
    } catch (e) {
      throw Exception('Failed to fetch users from repository: $e');
    }
  }
}