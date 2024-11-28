import 'package:gandang/data/login/login_datasource.dart';
import 'package:gandang/data/model/jwt_data.dart';
import 'package:gandang/data/model/token_dto.dart';
import 'package:gandang/data/repository/login_repository.dart';

class LoginViewModel {
  final LoginRepository repository = LoginRepository(LoginDataSource());

  Future<JwtData?> setLogin(TokenDto dto, String type) async {
    return await repository.setLogin(dto, type);
  }
}