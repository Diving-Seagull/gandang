import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gandang/view/login/login_view.dart';
import 'package:gandang/view/main/main_view.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/global/google_login_api.dart';
import '../../data/global/kakao_login_api.dart';
import '../global/color_data.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashViewState();

}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    GoogleLoginApi.instance.signOutGoogle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 2), () {
        // _kakaoCheckAuth();
        // _googleCheckAuth();
        moveLoginScreen();
        // moveMainScreen();
      });
    });
  }

  // 카카오 토큰 검사
  Future<void> _kakaoCheckAuth() async {
    var tokenInfo = await KakaoLoginApi.instance.checkRecentLogin();
    if (tokenInfo != null) {
        print('자동 로그인 카카오 토큰 정보 불러옴 ${tokenInfo.accessToken}');
        // JWT 요청
        moveMainScreen();
        return;
      }
    _googleCheckAuth();
  }

  // 구글 토큰 검사
  Future<void> _googleCheckAuth() async {
    GoogleSignInAccount? account = await GoogleLoginApi.instance.checkRecentLogin();
    if (account != null) {
        GoogleSignInAuthentication auth = await account.authentication;
        print('자동 로그인 구글 토큰 정보 불러옴 ${auth.accessToken}');
        //JWT 요청
        moveMainScreen();
        return;
      }
    print('구글 자동 로그인 실패');
    moveLoginScreen();
  }
  //
  // void checkRegister() async {
  //   var member = await viewModel.getMember();
  //   if(member == null) {
  //     moveLoginScreen();
  //   }
  //   else if(member.teamId == null) {
  //     moveTypeScreen();
  //   }
  //   else {
  //     moveMainScreen();
  //   }
  // }
  //
  // 로그인 화면 이동
  void moveLoginScreen() {
    if (mounted) {
      Navigator.pop(context); //Splash 화면 제거
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => LoginView()));
    }
  }


  // 메인 화면 이동
  void moveMainScreen() {
    if (mounted) {
      Navigator.pop(context); //Splash 화면 제거
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => MainView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: ColorData.PRIMARY_COLOR,
        body: Center(
          child: Container(
            decoration: const BoxDecoration(
              color: ColorData.PRIMARY_COLOR,
            ),
            child: SvgPicture.asset('assets/images/splash-logo.svg'),
          // child: Image.asset('', width: 150, height: 54)),
        )
      )
    );
  }
}
