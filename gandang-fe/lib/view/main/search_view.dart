import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gandang/view/global/device_size.dart';
import 'package:gandang/view/global/path_paint.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global/color_data.dart';
import '../global/doughnut_paint.dart';

class SearchView extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchView();
}

class _SearchView extends ConsumerState<SearchView> {
  SharedPreferences? _preferences;
  final TextEditingController startController = TextEditingController(),
        finishController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _preferences = await SharedPreferences.getInstance();
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
              children: [
                _setSearch(),
                Container(
                  height: 6,
                  color: ColorData.CONTENTS_050,
                ),
                SingleChildScrollView(
                  child: _preferences == null ?
                  CircularProgressIndicator() : _recentSearchSection(),
                )
              ],
            )
        )
    );
  }

  Widget _setSearch() {
    return Container(
      width: DeviceSize.getWidth(context),
      height: 140,
      padding: const EdgeInsets.all(25),
      color: ColorData.COLOR_WHITE,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(flex: 1, child: PathPaint.instance.getPathWidget(16)),
          Expanded(flex: 6, child: _searchSection()),
          Expanded(flex: 1, child: _btnSection())
        ],
      ),
    );
  }

  Widget _searchSection() {
    return Container(
      width: 270,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: ColorData.COLOR_WHITE,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1.5,
          color: ColorData.PRIMARY_COLOR,
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(child: TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '출발지를 입력해주세요',
                  hintStyle: TextStyle(
                      fontSize: 14,
                      color: ColorData.CONTENTS_200
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.all(0)
              ),
              controller: startController,
              onSubmitted: (text){
                print(startController.text);
                _searchPath();
              },
          )),
          Flexible(child: Container(
            height: 1,
            color: ColorData.CONTENTS_100,
          )),
          Flexible(child: TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '도착지를 입력해주세요',
                  hintStyle: TextStyle(
                      fontSize: 14,
                      color: ColorData.CONTENTS_200
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.all(0)
              ),
              controller: finishController,
              onSubmitted: (text) {
                _searchPath();
              },
          )),
        ],
      ),
    );
  }

  Widget _btnSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          child: IconButton(onPressed: (){
            setState(() {
              var str = startController.text;
              startController.text = finishController.text;
              finishController.text = str;
            });
          },
              icon: SvgPicture.asset('assets/images/cross-direction.svg')),
        ),
        Flexible(
          child: IconButton(onPressed: (){
            setState(() {
              startController.text = '';
              finishController.text = '';
            });
          }, icon: SvgPicture.asset('assets/images/delete-logo.svg')),
        ),
      ],
    );
  }

  Widget _recentSearchSection() {
    var dataList = _preferences!.getStringList('recentSearch');
    if(dataList != null) {
      return Text('데이터가 없습니다.');
    }
    else {
      return Text('데이터가 없습니다.');
    }
  }

  void _searchPath() async {
    var start = startController.text;
    var finish = finishController.text;

    if(start.isEmpty || finish.isEmpty) {
      return;
    }
  }

}