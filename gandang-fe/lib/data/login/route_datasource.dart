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
import '../model/path_dto.dart';
import '../model/route_req.dart';
import '../model/routes_dto.dart';
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

  Future<List<SearchContent>?> getStarredRoutes(TokenDto tokenDto) async {
    String path = '$uriPath/routes/stars';
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

  Future<RoutesDto?> postRoutes(RouteReq req, TokenDto tokenDto) async {
    String path = '$uriPath/routes';
    headers['Authorization'] = 'Bearer ${tokenDto.social_token}';
    try{
      http.Response response =
          await RestApiSession.getPostUri(Uri.parse(path), headers, req);
      final int statusCode = response.statusCode;
      if(statusCode == 201){
        final Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var total_distance = jsonData['total_distance'];
        var has_tourspot = jsonData['has_tourspot'];
        List<dynamic> pathList = jsonData['path'];
        var path = pathList.map((item) => PathDto.fromJson(item)).toList();
        return RoutesDto(total_distance: total_distance, has_tourspot: has_tourspot, path: path);
      }
      else {
        print('postRoutes() 에러 발생 $statusCode');
        print('${response.body.toString()}');
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
          print(e);
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