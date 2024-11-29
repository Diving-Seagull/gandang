import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gandang/data/model/query_detail.dart';
import 'package:gandang/data/model/station_dto.dart';
import 'package:gandang/data/model/token_dto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../global/rest_api_session.dart';

class PlaceDataSource {
  final _uriPath = 'http://${RestApiSession.IP_PATH}:8080/api/bicycle-stations/nearest?';
  final kakao_url = "https://dapi.kakao.com/v2/local/search/keyword.json?size=1&query=";

  final Map<String, String> headers = {
    'Content-Type': 'application/json;charset=UTF-8',
    'Accept': 'application/json'
  };

  Future<QueryDetail?> getLatLngtoString(String query) async {
    final urlPath = '$kakao_url$query';
    await dotenv.load(fileName: 'assets/config/.env');
    var kakao_token = dotenv.env['KAKAO_REST_API_KEY'];
    print(kakao_token);
    headers['Authorization'] = 'KakaoAK ${kakao_token}';
    try{
      http.Response response =
          await RestApiSession.getUrl(Uri.parse(urlPath), headers);
      final int statusCode = response.statusCode;
      if(statusCode == 200){
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        print(data);
        if (data['documents'].isNotEmpty) {
          final searched = data['documents'][0];
          Map<String, dynamic> result = Map();
          result['address_name'] = searched['address_name'];
          result['x'] = searched['x'];
          result['y'] = searched['y'];
          return QueryDetail.fromJson(result);
        }
      }
      else {
        print('getLatLngtoString() 에러 발생 $statusCode');
      }
    } on http.ClientException {
      print('인터넷 문제 발생');
    } on TimeoutException {
      print('$urlPath TimeoutException');
    }
    return null;
  }

  Future<StationDto?> getBicycleStation(double lat, double lng, TokenDto tokenDto) async {
    var path = '$_uriPath&latitude=$lat&longitude=$lng';
    headers['Authorization'] = 'Bearer ${tokenDto.social_token}';
    try{
      http.Response response =
          await RestApiSession.getUrl(Uri.parse(path), headers);

      final int statusCode = response.statusCode;

      if(statusCode == 200){
        return StationDto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      }
      else {
        print('getBicycleStation() 에러 발생 $statusCode');
      }
    } on http.ClientException {
      print('인터넷 문제 발생');
    } on TimeoutException {
      print('$path TimeoutException');
    }
    return null;
  }

}