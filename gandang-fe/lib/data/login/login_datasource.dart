import 'dart:async';
import 'dart:convert';

import 'package:gandang/data/model/jwt_data.dart';
import 'package:http/http.dart' as http;

import '../global/rest_api_session.dart';
import '../model/member.dart';
import '../model/token_dto.dart';

class LoginDataSource {
  final _uriPath = 'http://${RestApiSession.IP_PATH}:8080/api';

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  Future<JwtData?> postTokenInfo(TokenDto tokenDto, String type) async {
    String path = '$_uriPath/auth/$type';
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

  Future<Member?> getMember(TokenDto tokenDto) async {
    try {
      headers['Authorization'] = 'Bearer ${tokenDto.social_token}';
      http.Response response =
        await RestApiSession.getUrl(Uri.parse('$_uriPath/member'), headers);
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        Map<String, dynamic> result =
        json.decode(utf8.decode(response.bodyBytes));
        result.remove('created_at');
        result.remove('updated_at');
        return Member.fromJson(result);
      } else if (statusCode == 401) {
        print('JWT 인증 시간 초과');
      } else {
        print('getMember() 에러 발생 $statusCode');
      }
    } on http.ClientException {
      print('인터넷 문제 발생');
    } on TimeoutException {
      print('getMember TimeoutException');
    }
    return null;
  }
}