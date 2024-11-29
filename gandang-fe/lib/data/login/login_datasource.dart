import 'dart:async';
import 'dart:convert';

import 'package:gandang/data/model/jwt_data.dart';
import 'package:http/http.dart' as http;

import '../global/rest_api_session.dart';
import '../model/token_dto.dart';

class LoginDataSource {
  final _uriPath = 'http://${RestApiSession.IP_PATH}:8080/api/auth';

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  Future<JwtData?> postTokenInfo(TokenDto tokenDto, String type) async {
    String path = '$_uriPath/$type';
    try{
      http.Response response =
        await RestApiSession.getPostUri(Uri.parse(path), headers, tokenDto.toJson());

      final int statusCode = response.statusCode;

      if(statusCode == 200){
        return JwtData.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      }
      else {
        print('postTokenInfo() 에러 발생 $statusCode');
      }
    } on http.ClientException {
      print('인터넷 문제 발생');
    } on TimeoutException {
      print('$path TimeoutException');
    }
    return null;
  }
}