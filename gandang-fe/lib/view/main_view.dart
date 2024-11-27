import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainView extends ConsumerStatefulWidget{
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainView();
}

class _MainView extends ConsumerState<MainView> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  @override
  void initState() {
    super.initState();
    _initFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
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