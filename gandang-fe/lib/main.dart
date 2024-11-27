import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gandang/view/splash_view.dart';
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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupFCM();
  //Firebase 포그라운드 메시지 핸들러 등록
  FirebaseMessaging.onMessage.listen(showFlutterNotification);
  // Firebase 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await dotenv.load(fileName: 'assets/config/.env');

  KakaoSdk.init(
    nativeAppKey: '${dotenv.env['KAKAO_NATIVE_APP_KEY']}'
  );

  runApp(const GandangApp());
}

Future<void> setupFCM() async {
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
      ),
      home: const SplashView(),
    );
  }
}