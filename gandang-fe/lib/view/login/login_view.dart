import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandang/data/apple_login_api.dart';
import 'package:gandang/data/google_login_api.dart';
import 'package:gandang/data/kakao_login_api.dart';
import 'package:gandang/view/global/color_data.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

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
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('시작하기 전에'),
                              Row(
                                children: [
                                  Text('로그인'),
                                  Text('이 필요해요')
                                ],
                              ),
                              Text('3초면 시작할 수 있어요!')
                            ],
                          ),
                          _kakaoLoginBtn(context),
                          const SizedBox(height: 10),
                          _googleLoginBtn(context),
                          const SizedBox(height: 10),
                          _appleLoginBtn(context)
                        ],
                      )
                    ),
                  margin: EdgeInsets.symmetric(vertical: 30, horizontal: 25),
                ),
                Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 25, vertical: 10),
                  child: Text('로그인이 안되나요?',
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
  Widget _kakaoLoginBtn(BuildContext context) => Container(
      height: 58,
      decoration: BoxDecoration(
          color: const Color(0xFFFDE500),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorData.CONTENTS_050)
      ),
      child: TextButton(
        onPressed: () async {

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
}