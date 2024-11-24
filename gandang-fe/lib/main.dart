import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gandang/view/splash_view.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/config/.env');

  KakaoSdk.init(
    nativeAppKey: '${dotenv.env['KAKAO_NATIVE_APP_KEY']}'
  );

  runApp(const GandangApp());
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