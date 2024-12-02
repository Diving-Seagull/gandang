import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../global/color_data.dart';

class SpotView extends ConsumerStatefulWidget {
  final int selectedIndex;
  final String addressName;

  SpotView(this.selectedIndex, this.addressName);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SpotView(selectedIndex, addressName);


}

class _SpotView extends ConsumerState<SpotView> {
  final int selectedIndex;
  final String addressName;
  int second = 3;

  late Timer _timer;

  _SpotView(this.selectedIndex, this.addressName);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          second--;
        });
        if (second == 0) {
          _timer.cancel();
          Navigator.pop(context);
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    Color chooseColor = selectedIndex == 0 ? ColorData.PRIMARY_COLOR : ColorData.PRI_SEC;

    return Scaffold(
        body: SafeArea(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(onPressed: (){}, icon: SvgPicture.asset('assets/images/close-icon.svg', width: 35, height: 35)),
                    ),
                    Flexible(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        selectedIndex == 0 ?
                        SvgPicture.asset('assets/images/orange-hello.svg', width: 200, height: 180) :
                        SvgPicture.asset('assets/images/green-hello.svg', width: 200, height: 180),
                        const SizedBox(height: 25),
                        Text('행운이네요!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Text('이번 경로는 아름다운 경관으로 유명한',
                          style: TextStyle(
                              color: ColorData.CONTENTS_200,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('제주도의 ', style: TextStyle(
                                color: ColorData.CONTENTS_200,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            )),
                            Text('${addressName}', style: TextStyle(
                                color: chooseColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )),
                            Text('를 지나고 있어요', style: TextStyle(
                                color: ColorData.CONTENTS_200,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            ))
                          ],
                        )
                      ],
                    )),
                    Align(
                      alignment: Alignment.center,
                      child: Text('$second초 후 자동으로 화면이 전환돼요',
                        style: TextStyle(
                          color: ColorData.CONTENTS_100,
                          decoration: TextDecoration.underline,
                          decorationColor: ColorData.CONTENTS_100,
                        ),
                      ),
                    )
                  ],
                ))
        )
    );
  }

}