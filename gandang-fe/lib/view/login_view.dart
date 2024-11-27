import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandang/data/apple_login_api.dart';
import 'package:gandang/data/google_login_api.dart';
import 'package:gandang/data/kakao_login_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
                 print('카카오 액세스 토큰 정보 : $accessToken');
              },
                  child: const Text('카카오')),
              FilledButton(onPressed: () async{
                GoogleSignInAccount? account = await GoogleLoginApi.instance.signInWithGoogle();
                if(account != null) {
                  GoogleSignInAuthentication auth = await account.authentication;
                  print('구글 액세스 토큰 정보 : ${auth.accessToken}');
                }
              },
                  child: const Text('구글')),
              FilledButton(onPressed: () async{
                AuthorizationCredentialAppleID user = await AppleLoginApi.instance.signInWithApple();
                print('애플 액세스 토큰 정보 : ${user.identityToken}');
              },
                  child: const Text('Apple'))
            ],
          )
      ),
    );
  }
}