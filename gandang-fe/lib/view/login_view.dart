import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandang/data/kakao_login_api.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
          child: Column(
            children: [
              FilledButton(onPressed: () async{
                 var accessToken = await KakaoLoginApi.instance.signWithKakao();
                 print('카카오 토큰 정보 : $accessToken');
              },
                  child: const Text('카카오'))
            ],
          )
      ),
    );
  }
}