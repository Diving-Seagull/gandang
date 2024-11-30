import 'dart:async';
import 'dart:convert';

import 'package:gandang/data/model/add_star_dto.dart';
import 'package:gandang/data/model/jwt_data.dart';
import 'package:gandang/data/model/recommend_dto.dart';
import 'package:gandang/data/model/search_content.dart';
import 'package:gandang/data/model/search_data.dart';
import 'package:http/http.dart' as http;

import '../global/rest_api_session.dart';
import '../model/add_star_result.dart';
import '../model/token_dto.dart';

class RouteDataSource {
  final String uriPath;

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  RouteDataSource(this.uriPath);

  Future<List<SearchContent>?> getRecentRoutes(TokenDto tokenDto) async {
    String path = '$uriPath/routes';
    headers['Authorization'] = 'Bearer ${tokenDto.social_token}';
    try{
      http.Response response =
      await RestApiSession.getUrl(Uri.parse(path), headers);
      final int statusCode = response.statusCode;
      if(statusCode == 200){
        final Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> contentList = jsonData['content'];
        return contentList.map((item) => SearchContent.fromJson(item)).toList();
      }
      else {
        print('getStarRoutes() 에러 발생 $statusCode');
      }
    } on http.ClientException {
      print('인터넷 문제 발생');
    } on TimeoutException {
      print('$path TimeoutException');
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<AddStarResult?> postStarRoutes(int id, TokenDto tokenDto) async {
    String path = '$uriPath/routes/$id/star';
    headers['Authorization'] = 'Bearer ${tokenDto.social_token}';
    try{
      http.Response response =
      await RestApiSession.getNoBodyPostUri(Uri.parse(path), headers);
      final int statusCode = response.statusCode;
      if(statusCode == 201){
        return AddStarResult.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        print('postStarRoutes() 에러 발생 $statusCode');
      }
    } on http.ClientException {
      print('인터넷 문제 발생');
    } on TimeoutException {
      print('$path TimeoutException');
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<List<RecommendDto>?> getRecommendRoutes(String query, TokenDto tokenDto) async {
    String path = '$uriPath/routes/recommendations?currentAddress=$query';
    headers['Authorization'] = 'Bearer ${tokenDto.social_token}';
    try{
      print(query);
      http.Response response =
          await RestApiSession.getUrl(Uri.parse(path), headers);
      final int statusCode = response.statusCode;
      if(statusCode == 200){
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        try{
          return data.map((item) => RecommendDto.fromJson(item)).toList();
        }
        catch (e) {
          print(data);
        }
      }
      else {
        print('getRecommendRoutes() 에러 발생 $statusCode');
      }
    } on http.ClientException {
      print('인터넷 문제 발생');
    } on TimeoutException {
      print('$path TimeoutException');
    } catch (e) {
      print(e);
    }
    return null;
  }
}