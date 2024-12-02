import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandang/view/global/color_data.dart';
import 'package:gandang/view/login/splash_view.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

// 최상단에 위치해 있어야 함.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드 상태에서 수신된 메시지 처리
  print("Handling a background message: ${message.messageId}");
  showFlutterNotification(message);
}

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true);

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NaverMapSdk.instance.initialize(
      clientId: '${dotenv.env['NAVER_MAP_KEY']}',     // 클라이언트 ID 설정
      onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed")
  );

  await setupFCM();
  //Firebase 포그라운드 메시지 핸들러 등록
  FirebaseMessaging.onMessage.listen(showFlutterNotification);
  // Firebase 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  KakaoSdk.init(
    nativeAppKey: '${dotenv.env['KAKAO_NATIVE_APP_KEY']}'
  );

  runApp(const ProviderScope(child: GandangApp()));
}

Future<void> _initFcmToken() async {
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

Future<void> setupFCM() async {
    await _initFcmToken();

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    var initialzationSettingsIOS = const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    var initializationSettingsAndroid = const AndroidInitializationSettings(
        '@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initialzationSettingsIOS);

    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (notificationResponse) {
            // notification 클릭 이벤트
            print('notification 클릭 이벤트 발생!');
            // notification 데이터 불러오기
            // notificationResponse.payload
          }
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
    else if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (message.notification != null && android != null) {
    _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      NotificationDetails(
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

class GandangApp extends StatelessWidget {
  const GandangApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '간당',
      theme: ThemeData(
        // Ripple 효과 비활성화
          splashFactory: NoSplash.splashFactory,
          scaffoldBackgroundColor: ColorData.COLOR_WHITE, //scaffold background color
          primaryColor: ColorData.PRIMARY_COLOR,
          fontFamily: "Pretendard",
          // textSelectionTheme: const TextSelectionThemeData(
          //     cursorColor: ColorData.FOCUS_COLOR, //textfield cursor color
          //     selectionHandleColor: ColorData.FOCUS_COLOR, // textfield handle color
          //     selectionColor: ColorData.FOCUS_COLOR // textfield selection color
          // )
      ),
      home: const SplashView(),
    );
  }
}