import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gandang/data/model/searched_info.dart';
import 'package:gandang/data/provider/place_provider.dart';
import 'package:gandang/view/global/device_size.dart';
import 'package:gandang/view/global/color_data.dart';
import 'package:gandang/view/global/no_animation_route.dart';
import 'package:gandang/view/global/path_paint.dart';
import 'package:gandang/view/main/search_result_view.dart';
import 'package:gandang/view/main/search_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/global/location_service.dart';
import '../../data/model/recommend_dto.dart';
import '../../data/model/token_dto.dart';
import '../../data/provider/route_provider.dart';

class MainView extends ConsumerStatefulWidget{
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainView();
}

class _MainView extends ConsumerState<MainView> {
  // NaverMapController 객체의 비동기 작업 완료를 나타내는 Completer 생성
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  late NOverlayImage _customMarkerImage;
  StreamSubscription<Position>? _positionStream;
  late NaverMapController _mapController;
  late NMarker user_marker;
  late Position position;

  final recommendProvider = FutureProvider.family<List<RecommendDto>, String>((ref, str) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String token = pref.getString('jwtToken')!;
      var result = await ref.read(routeRepositoryProvider).getRecommendRoutes(str, TokenDto(token));
      return result!;
    } catch(e) {
      throw e;
    }
  });

  @override
  void initState() {
    super.initState();
    _customMarkerImage = const NOverlayImage.fromAssetImage('assets/images/orange-now.png');
    user_marker = NMarker(id: DateTime.now().toIso8601String(),
        position: const NLatLng(0, 0),
        icon: _customMarkerImage
    );
  }

  /// 위치 변화 감지 시작
  void _startListeningToLocationChanges() async {
    // 권한 확인 및 요청
    final hasPermission = await LocationService.requestLocationPermission();
    if (!hasPermission) {
      return;
    }
    // 위치 변화 스트림 설정
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 최소 이동 거리(미터)
      ),
    ).listen((Position position) {
      this.position = position;
      _addMarker();
    });

    setNowLocation();
  }

  void setNowLocation() async {
    position = await Geolocator.getCurrentPosition();
    _addMarker();
  }

  Future<String?> getLocation() async {
    var pos = await Geolocator.getCurrentPosition();
    var repository = ref.read(placeRepositoryProvider);
    return await repository.getAddressFromCoordinates(pos.latitude, pos.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
            children: [
              _naverMap(),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: DeviceSize.getWidth(context),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      height: 75,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Flexible(flex: 3, child: Material(
                              color: ColorData.CONTENTS_100,
                              elevation: 5,
                              borderRadius: BorderRadius.circular(1000),
                              child: TextField(
                                decoration: InputDecoration(
                                    prefixIcon: Padding(padding: EdgeInsets.all(10),
                                        child: Image.asset('assets/images/search-icon.png', width: 14, height: 14)),
                                    border: InputBorder.none,
                                    hintText: '목적지를 입력해주세요',
                                    hintStyle: const TextStyle(
                                        fontSize: 14,
                                        color: ColorData.CONTENTS_200
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(1000),
                                        borderSide: const BorderSide(color: ColorData.PRIMARY_COLOR)
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(1000),
                                        borderSide: const BorderSide(color: ColorData.PRIMARY_COLOR)
                                    ),
                                    filled: true,
                                    fillColor: ColorData.COLOR_WHITE,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.all(10)
                                ),
                                readOnly: true,
                                onTap: () {
                                  if(Platform.isAndroid) {
                                    // 애니메이션 없이 이동
                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1, animation2) => SearchView(),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration: const Duration(microseconds: 300),
                                        )
                                    );
                                  }
                                  else {
                                    // 애니메이션 없이 이동
                                    Navigator.push(
                                        context,
                                        NoAnimationRoute(pageBuilder: PageRouteBuilder(
                                          pageBuilder: (context, animation1, animation2) => SearchView(),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration: const Duration(microseconds: 300),
                                        ).pageBuilder)
                                    );
                                  }
                                },
                              ),
                            )),
                            Flexible(flex: 1,
                                child: Material(
                                  color: ColorData.CONTENTS_100,
                                  borderRadius: BorderRadius.circular(1000),
                                  elevation: 5,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: ColorData.PRIMARY_COLOR,
                                          borderRadius: BorderRadius.circular(1000),
                                          border: Border.all(color: ColorData.PRIMARY_COLOR)
                                      ),
                                      child: TextButton(onPressed: (){},
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(0),
                                        ),
                                        child: const Text('My >',
                                          style: TextStyle(
                                            color: ColorData.COLOR_WHITE
                                          ),
                                        ),
                                      )
                                  ),
                                )
                            )
                        ],
                      )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(flex: 3, child: SizedBox()),
                          Flexible(child: SizedBox(
                            width: 45,
                            height: 45,
                            child: Material(
                                  color: ColorData.COLOR_WHITE,
                                  borderRadius: BorderRadius.circular(1000),
                                  elevation: 5,
                                  child: IconButton(onPressed: (){},
                                      icon: SvgPicture.asset('assets/images/main-1.svg')
                                  ),
                                )
                          ))
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(flex: 3, child: SizedBox()),
                          Flexible(child: SizedBox(
                              width: 45,
                              height: 45,
                              child: Material(
                                color: ColorData.COLOR_WHITE,
                                borderRadius: BorderRadius.circular(1000),
                                elevation: 5,
                                child: IconButton(onPressed: (){},
                                    icon: SvgPicture.asset('assets/images/main-2.svg')
                                ),
                              )
                          ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 45,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(flex: 3, child: SizedBox()),
                          Flexible(child: SizedBox(
                              width: 45,
                              height: 45,
                              child: Material(
                                color: ColorData.COLOR_WHITE,
                                borderRadius: BorderRadius.circular(1000),
                                elevation: 5,
                                child: IconButton(onPressed: (){
                                  setNowLocation();
                                  _moveCameraTo();
                                },
                                    icon: SvgPicture.asset('assets/images/loc-icon.svg')
                                ),
                              )
                          ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DraggableScrollableSheet(
                  initialChildSize: 0.1, // 초기 높이
                  minChildSize: 0.1, // 최소 높이
                  maxChildSize: 0.6, // 최대 높이
                  builder: (BuildContext context, ScrollController scrollController) {
                    return Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(40)),
                            boxShadow: [
                              BoxShadow(color: ColorData.CONTENTS_200,
                                  blurRadius: 10,
                                  spreadRadius: 2)
                            ]
                        ),
                        child: Column(
                          children: [
                            // 회색 바
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0),
                              child: Container(
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: ColorData.CONTENTS_100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            FutureBuilder(future: getLocation(), builder: (context, result) {
                              if (result.hasData) {
                                var watch = ref.watch(
                                    recommendProvider(result.requireData!));
                                return watch.when(data: (dataList) {
                                  return Expanded(
                                    child: ListView.builder(
                                      controller: scrollController,
                                      itemCount: dataList.length,
                                      itemBuilder: (BuildContext context,
                                          int index) {
                                        var addressList = dataList[index]
                                            .end_address.split(' ');
                                        var addr = '${addressList[2]}';
                                        var result_addr = addressList.skip(2).join(' ');
                                        return Padding(
                                          padding: EdgeInsets.all(25),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(addr,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22,
                                                    color: ColorData.PRIMARY_COLOR
                                                    ),
                                                  ),
                                                  const Text(' 근처 코스를',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 22
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const Text('찾고 계신가요?',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                  color: ColorData.CONTENTS_300
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Text('${dataList[index].visit_count}명',
                                                    style: const TextStyle(
                                                        color: ColorData.PRIMARY_COLOR,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  const Text('이 이곳을 선택했어요!')
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Container(height: 80, padding: EdgeInsets.symmetric(vertical: 10), child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(flex: 1, child: SvgPicture.asset('assets/images/thumb-up.svg')),
                                                  Expanded(flex: 1, child: PathPaint.instance.getPathWidget(10)),
                                                  Expanded(flex: 6, child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(result_addr ,
                                                        style: const TextStyle(
                                                            overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Text(result.requireData!.split(' ').skip(2).join(' '),
                                                        style: const TextStyle(
                                                            overflow: TextOverflow.ellipsis
                                                        ),
                                                      ),
                                                    ],
                                                  ))
                                                ]
                                              )),
                                              const SizedBox(height: 10),
                                              _destDetailSection(result.requireData!, dataList[index])
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }, error: (error, stack) {
                                  return Center(child: Text('에러 발생'));
                                }, loading: () {
                                  return Center(
                                      child: CircularProgressIndicator());
                                });
                              }
                              else{
                                return Center(child: Text('추천 경로가 없습니다.'));
                              }
                            }
                            )
                          ],
                        )
                    );
                  }
              )
            ]
          )
      )
    );
  }

  Widget _destDetailSection(String start_addr, RecommendDto endData) {
    return Container(
      width: DeviceSize.getWidth(context),
      height: 175,
      padding: const EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 20),
      decoration: BoxDecoration(
          color: ColorData.COLOR_WHITE,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorData.PRIMARY_COLOR),
          boxShadow: [
            BoxShadow(color: ColorData.COLOR_BLACK.withOpacity(0.2) ,
                offset: const Offset(0, 3), blurRadius: 20)]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('예상 소요 시간',
            style: TextStyle(
                color: ColorData.CONTENTS_200,
                fontWeight: FontWeight.bold
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('1시간 2분',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    color: ColorData.PRIMARY_COLOR
                ),
              ),
              const SizedBox(width: 10),
              const Text('|', style: TextStyle(color: ColorData.CONTENTS_100)),
              const SizedBox(width: 10),
              Text("23.3km",
                style: TextStyle(
                    color: ColorData.CONTENTS_200,
                    fontWeight: FontWeight.w500,
                    fontSize: 12
                ),
              )
            ],
          ),
          const Text('※ 실제 소요 시간은 교통 상황에 따라 다를 수 있습니다.',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 10,
              color: ColorData.CONTENTS_200,
            ),
          ),
          const SizedBox(height: 10),
          Container(
              width: DeviceSize.getWidth(context),
              height: 30,
              decoration: BoxDecoration(
                color: ColorData.PRIMARY_COLOR,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextButton(
                onPressed: () async {
                  // 애니메이션 없이 이동
                  Navigator.push(
                      context,
                      NoAnimationRoute(pageBuilder: PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => SearchResultView(
                            SearchedInfo(start_addr, position.latitude, position.longitude,
                                endData.end_address, endData.end_latitude, endData.end_longitude)
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: const Duration(microseconds: 300),
                      ).pageBuilder)
                  );
                 },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, // 안쪽 여백 직접 조정
                ), child: const Text('경로 안내하기 >' ,
                style: TextStyle(
                    color: ColorData.COLOR_WHITE,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                ),
              ),
              )
          )
        ],
      ),
    );
  }

  Widget _naverMap() {
    return NaverMap(
      options: const NaverMapViewOptions(
        indoorEnable: false,             // 실내 맵 사용 가능 여부 설정
        locationButtonEnable: false,    // 위치 버튼 표시 여부 설정
        consumeSymbolTapEvents: false,  // 심볼 탭 이벤트 소비 여부 설정
      ),
      onMapReady: (controller) {
        _mapController = controller;
        _mapController.addOverlay(user_marker);
        mapControllerCompleter.complete(controller);  // Completer에 지도 컨트롤러 완료 신호 전송
        _startListeningToLocationChanges();
        print("onMapReady");
      },
    );
  }

  void _addMarker() {
    user_marker.setPosition(NLatLng(position.latitude, position.longitude));
    _moveCameraTo();
  }

  void _moveCameraTo() {
    _mapController.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(position.latitude, position.longitude), zoom: 15,));
  }
}