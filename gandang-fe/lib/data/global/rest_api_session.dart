import 'dart:convert';

import 'package:http/http.dart' as http;

class RestApiSession {
  // static const String IP_PATH = '172.20.10.9';
  static const String IP_PATH = '192.168.0.99';
  // static const String IP_PATH = '10.0.2.2';

  //GET 통신 설정
  static getUrl(Uri uri, Map<String, String> headers) async {
    return await http.get(uri, headers: headers)
    .timeout(const Duration(seconds: 30));
  }

  static getNoBodyPostUri(Uri uri, Map<String, String> headers) async {
    return await http.post(uri, headers: headers)
        .timeout(const Duration(seconds: 30)); //Timeout 설정
  }

  //POST 통신 설정
  static getPostUri(Uri uri, Map<String, String> headers, dynamic data) async {
    return await http.post(uri, headers: headers, body: json.encode(data))
        .timeout(const Duration(seconds: 30)); //Timeout 설정
  }

  static getPutUri(Uri uri, Map<String, String> headers, dynamic data) async {
    return await http.put(uri, headers: headers, body: json.encode(data))
        .timeout(const Duration(seconds: 30));
  }

  static getDeleteUri(Uri uri, Map<String, String> headers) async {
    return await http.delete(uri, headers: headers)
        .timeout(const Duration(seconds: 30));
  }
}