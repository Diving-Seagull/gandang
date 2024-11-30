import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gandang/data/model/add_star_dto.dart';
import 'package:gandang/data/model/searched_info.dart';
import 'package:gandang/data/model/star_content.dart';
import 'package:gandang/data/model/star_data.dart';
import 'package:gandang/data/model/token_dto.dart';
import 'package:gandang/data/provider/place_provider.dart';
import 'package:gandang/data/provider/star_provider.dart';
import 'package:gandang/view/global/device_size.dart';
import 'package:gandang/view/global/path_paint.dart';
import 'package:gandang/view/main/search_result_view.dart';
import 'package:gandang/viewmodel/place_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/login/star_datasource.dart';
import '../../data/model/add_star_result.dart';
import '../../data/model/query_detail.dart';
import '../global/color_data.dart';
import '../global/doughnut_paint.dart';
import '../global/no_animation_route.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchView();
}

class _SearchView extends ConsumerState<SearchView> {
  final TextEditingController startController = TextEditingController(),
        finishController = TextEditingController();
  final PlaceViewModel _placeViewModel = PlaceViewModel();

  // 사용자 데이터를 비동기로 관리하는 StateNotifier
  final starProvider = FutureProvider<List<StarContent>?>((ref) async {
    try{
      SharedPreferences pref = await SharedPreferences.getInstance();
      String token = pref.getString('jwtToken')!;
      final repository = ref.read(starRepositoryProvider);
      var result = await repository.getStarRoutes(TokenDto(token));
      print('starProvider $result');
      return result;
    } catch(e) {
      throw e;
    }
  });

  final addStarProvider = FutureProvider.family<AddStarResult?, int>((ref, id) async {
    try{
      SharedPreferences pref = await SharedPreferences.getInstance();
      String token = pref.getString('jwtToken')!;
      final repository = ref.read(starRepositoryProvider);
      var result = await repository.postStarRoute(id, TokenDto(token));
      print('addStarProvider ${result!.star_id}');
      return result;
    } catch(e) {
      throw e;
    }
  });

  final placeDetailProvider = FutureProvider.family<QueryDetail?, String>((ref, str) async {
    final repository = ref.watch(placeRepositoryProvider);
    return await repository.getLatLngtoString(str);
  });

  @override
  Widget build(BuildContext context) {
    var recentSearchState = ref.watch(starProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _setSearch(),
            Container(
              height: 6,
              color: ColorData.CONTENTS_050,
            ),
            recentSearchState.when(
                data: (recentSearchList) {
                  return _recentSearchSection(recentSearchList!);
                },
                error: (error, stack) => Text('에러 발생'),
                loading: () => Center(child: Text('로딩중...'))
            ),
          ],
        ),
      )
    );
  }

  Widget _setSearch() {
    return Container(
      width: DeviceSize.getWidth(context),
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
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
                print(text);
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

  Widget _recentSearchSection(List<StarContent> dataList) {
    return Expanded(child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('최근 기록',
              style: TextStyle(
                color: ColorData.CONTENTS_300,
                fontSize: 14,
                fontWeight: FontWeight.bold
              ),
            ),
            Expanded(child: ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index){
                    var data = dataList[index];
                    return Container(
                        height: 75,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: GestureDetector(
                            onTap: () {
                              _searchRecentPath(data);
                            },
                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                Expanded(flex: 1, child:
                                    data.starred ?
                                    IconButton(onPressed: (){

                                    }, icon: SvgPicture.asset('assets/images/filled-star.svg')) :
                                    IconButton(onPressed: (){
                                      var watch = ref.watch(addStarProvider(data.id));
                                      watch.whenData((data) {
                                        ref.refresh(starProvider);
                                      });
                                    }, icon: SvgPicture.asset('assets/images/non-star.svg'))
                                ),
                                Expanded(flex: 1, child: PathPaint.instance.getPathWidget(10)),
                                Expanded(flex: 8, child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data.start_address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                    Text(data.end_address,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ))
                              ],
                          )
                        )
                    );
                })
            )
      ],
    )));
  }

  void _searchPath() async {
    var start = startController.text;
    var finish = finishController.text;

    if(start.isEmpty || finish.isEmpty) {
      return;
    }
    try{
      var start_address = await _placeViewModel.getLatLngtoQuery(start);
      var end_address = await _placeViewModel.getLatLngtoQuery(finish);

      if(start_address != null && end_address != null) {
        var info = SearchedInfo(
            start_address.address_name, start_address.x, start_address.y,
            end_address.address_name, end_address.x, end_address.y, start, finish);
        // 애니메이션 없이 이동
        Navigator.push(
            context,
            NoAnimationRoute(pageBuilder: PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => SearchResultView(info),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: const Duration(microseconds: 300),
            ).pageBuilder)
        );
      }
    } catch(e) {
      print(e);
    }
  }

  void _searchRecentPath(StarContent content) {
    var info = SearchedInfo(
        content.start_address, content.start_latitude, content.start_longitude,
        content.end_address, content.end_latitude, content.end_longitude);
    // 애니메이션 없이 이동
    Navigator.push(
        context,
        NoAnimationRoute(pageBuilder: PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SearchResultView(info),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: const Duration(microseconds: 300),
        ).pageBuilder)
    );
    // TODO: 선택한 데이터의 출발지 목적지 장소 텍스트 초기화
    startController.text = '';
    finishController.text = '';
  }
}