import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandang/data/global/apple_login_api.dart';
import 'package:gandang/data/model/jwt_data.dart';
import 'package:gandang/data/model/token_dto.dart';
import 'package:gandang/provider/login_notifier.dart';
import 'package:gandang/provider/login_provider.dart';
import 'package:gandang/view/global/color_data.dart';
import 'package:gandang/viewmodel/login_viewmodel.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../data/global/google_login_api.dart';
import '../../data/global/kakao_login_api.dart';
import '../main/main_view.dart';

class LoginView extends ConsumerWidget {
  LoginView({super.key});
  final LoginViewModel _viewModel = LoginViewModel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('시작하기 전에',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text('로그인',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: ColorData.PRIMARY_COLOR
                                    ),
                                  ),
                                  Text('이 필요해요',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 20),
                              Text('3초면 시작할 수 있어요!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ColorData.CONTENTS_200
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 60),
                          _kakaoLoginBtn(context, ref),
                          const SizedBox(height: 10),
                          _googleLoginBtn(context),
                          const SizedBox(height: 10),
                          _appleLoginBtn(context)
                        ],
                      )
                    ),
                ),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 25, vertical: 10),
                  child: const Text('로그인이 안되나요?',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: ColorData.CONTENTS_100,
                      color: ColorData.CONTENTS_100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
          ]
        ),
      ),
    );
  }
  // 카카오 로그인 버튼
  Widget _kakaoLoginBtn(BuildContext context, WidgetRef ref) => Container(
      height: 58,
      decoration: BoxDecoration(
          color: const Color(0xFFFDE500),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorData.CONTENTS_050)
      ),
      child: TextButton(
        onPressed: () async {
          OAuthToken? token = await KakaoLoginApi.instance.signWithKakao();
          if(token != null) {
            //로그인 성공
            print('카카오 액세스 토큰 정보 : ${token.accessToken}');
            var prefer = await SharedPreferences.getInstance();
            var firebase_token = prefer.getString('fcmToken');
            var data = TokenDto(token.accessToken, firebase_token!);
            var result = await _viewModel.setLogin(data, 'kakao');
            if(result != null) {
              print('카카오 로그인 정보 $result');
              await prefer.setString('jwtToken', result.token);
              _moveMainScreen(context);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero, // 안쪽 여백 직접 조정
        ), child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(flex: 1, child:
          Container(
              margin: EdgeInsets.only(left: 20),
              child: Image.asset('assets/images/kakao-logo.png', width: 20, height: 20))),
          const Flexible(flex: 3, child: Text('카카오로 시작하기',
              style: TextStyle(color: Colors.black, fontFamily: "Pretendard",
                  fontSize: 16, fontWeight: FontWeight.w700))),
          const Flexible(child: SizedBox(width: 20, height: 20))
        ],
      ),
      )
  );

  // 구글 로그인 버튼
  Widget _googleLoginBtn(BuildContext context) => Container(
          height: 58,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorData.CONTENTS_050)
          ),
          child: TextButton(
            onPressed: () async {
              GoogleSignInAccount userInfo = await GoogleLoginApi.instance.signInWithGoogle();
              var auth = await userInfo.authentication;
              if(auth.accessToken != null) {
                  print('구글 액세스 토큰 : ${auth.accessToken}');
                  var prefer = await SharedPreferences.getInstance();
                  var firebase_token = prefer.getString('fcmToken');
                  var data = TokenDto(auth.accessToken!, firebase_token!);
                  var result = await _viewModel.setLogin(data, 'google');
                  if(result != null) {
                    print('구글 로그인 정보 $result');
                    await prefer.setString('jwtToken', result.token);
                    _moveMainScreen(context);
                  }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, // 안쪽 여백 직접 조정
            ), child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(flex: 1, child:
              Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Image.asset('assets/images/google-logo.png', width: 20, height: 20))),
              const Flexible(flex: 3, child: Text('Google로 시작하기',
                  style: TextStyle(color: Colors.black, fontFamily: "Pretendard",
                      fontSize: 16, fontWeight: FontWeight.w700))),
              const Flexible(child: SizedBox(width: 20, height: 20))
            ],
          ),
          )
  );

  // Apple 로그인 버튼
  Widget _appleLoginBtn(BuildContext context) => Container(
      height: 58,
      decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () async {
          AuthorizationCredentialAppleID? login = await AppleLoginApi.instance.signInWithApple();
          if(login != null) {
            print('Apple 로그인 정보 : ${login.identityToken}');
            var prefer = await SharedPreferences.getInstance();
            var firebase_token = prefer.getString('fcmToken');
            var data = TokenDto(login.identityToken!, firebase_token!);
            var result = await _viewModel.setLogin(data, 'apple');
            if(result != null) {
              print('Apple 로그인 정보 ${result.token}');
              await prefer.setString('jwtToken', result.token);
              _moveMainScreen(context);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero, // 안쪽 여백 직접 조정
        ), child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(flex: 1, child:
          Container(
              margin: EdgeInsets.only(left: 20),
              child: Image.asset('assets/images/apple-logo.png', width: 20, height: 20))),
          const Flexible(flex: 3, child: Text('Apple로 시작하기',
              style: TextStyle(color: Colors.white, fontFamily: "Pretendard",
                  fontSize: 16, fontWeight: FontWeight.w700))),
          const Flexible(child: SizedBox(width: 20, height: 20))
        ],
      ),
      )
  );

  void _moveMainScreen(BuildContext context) {
    if(context.mounted) {
      Navigator.pop(context); //Splash 화면 제거
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => MainView()));
    }
  }
}