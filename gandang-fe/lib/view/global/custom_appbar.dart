import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar {

  static PreferredSizeWidget getNavigationBar(BuildContext context, String title, Function func) {
    return PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: Container(
        height: 80,
        child: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          leading: Align(
            widthFactor: 1.0,
            alignment: Alignment.center,
            child: GestureDetector(child: Image.asset('assets/images/icon_left.png', width: 24, height: 24),  onTap: () {
                func();
            }),
          ),
          middle: Text(title, style: TextStyle(fontSize: 18, color: Colors.black)),
          border: Border(bottom: BorderSide(color: Colors.transparent)), //그림자 제거
        ),
      ),
    );
  }

  static PreferredSizeWidget getTitleBar(BuildContext context, String title) {
    return PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: Container(
        height: 80,
        child: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          middle: Text(title, style: TextStyle(fontSize: 18, color: Colors.black)),
          trailing: Text('로그아웃'),
          border: Border(bottom: BorderSide(color: Colors.transparent)), //그림자 제거
        ),
      ),
    );
  }
}