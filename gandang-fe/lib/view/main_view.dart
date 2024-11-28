import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainView extends ConsumerStatefulWidget{
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainView();
}

class _MainView extends ConsumerState<MainView> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // NaverMapController 객체의 비동기 작업 완료를 나타내는 Completer 생성
  final Completer<NaverMapController> mapControllerCompleter = Completer();

  @override
  void initState() {
    super.initState();
    _initFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: NaverMap(
          options: const NaverMapViewOptions(
            indoorEnable: true,             // 실내 맵 사용 가능 여부 설정
            locationButtonEnable: false,    // 위치 버튼 표시 여부 설정
            consumeSymbolTapEvents: false,  // 심볼 탭 이벤트 소비 여부 설정
          ),
          onMapReady: (controller) async {                // 지도 준비 완료 시 호출되는 콜백 함수
            mapControllerCompleter.complete(controller);  // Completer에 지도 컨트롤러 완료 신호 전송
            log("onMapReady", name: "onMapReady");
          },
        ),
      ),
    );
  }

  void _initFcmToken() async {
    // Firebase 초기화 후 토큰 저장하기
    try {
      String? token = await _firebaseMessaging.getToken();
      var preference = await SharedPreferences.getInstance();
      String? saved_token = preference.getString("fcmToken");
      print('FCM Token: $token');
      if (token != null) {
        // fcm 토큰 저장
        if(saved_token == null || saved_token != token) {
          print('새로운 FCM 토큰 저장');
          await preference.setString('fcmToken', token);
        }
      }
    } catch (e) {
      print('Error fetching FCM token: $e');
    }
  }
}