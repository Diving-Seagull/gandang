import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gandang/data/global/device_size.dart';
import 'package:gandang/view/global/color_data.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/global/location_service.dart';

class MainView extends ConsumerStatefulWidget{
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainView();
}

class _MainView extends ConsumerState<MainView> {
  // NaverMapController 객체의 비동기 작업 완료를 나타내는 Completer 생성
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  StreamSubscription<Position>? _positionStream;
  late NaverMapController _mapController;
  late NOverlayImage _customMarkerImage;
  late NMarker user_marker;
  late Position position;

  @override
  void initState() {
    super.initState();
    _customMarkerImage = const NOverlayImage.fromAssetImage('assets/images/orange-now.png');
    user_marker = NMarker(id: DateTime.now().toIso8601String(),
        position: NLatLng(0, 0),
        icon: _customMarkerImage
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListeningToLocationChanges();
    });
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
  }

  void setNowLocation() async {
    position = await Geolocator.getCurrentPosition();
    _addMarker();
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
                                  // 애니메이션 없이 이동
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) => SearchView(),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
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
                  initialChildSize: 0.2, // 초기 높이
                  minChildSize: 0.2, // 최소 높이
                  maxChildSize: 0.8, // 최대 높이
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
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: 1,
                                itemBuilder: (BuildContext context, int index) {
                                  return Center(
                                    child: Text('Item $index'),
                                  );
                                },
                              ),
                            ),
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

  Widget _naverMap() {
    return NaverMap(
      options: const NaverMapViewOptions(
        indoorEnable: false,             // 실내 맵 사용 가능 여부 설정
        locationButtonEnable: false,    // 위치 버튼 표시 여부 설정
        consumeSymbolTapEvents: false,  // 심볼 탭 이벤트 소비 여부 설정
      ),
      onMapReady: (controller) async {
        _mapController = controller;
        mapControllerCompleter.complete(controller);  // Completer에 지도 컨트롤러 완료 신호 전송
        print("onMapReady");
      },
    );
  }

  void _addMarker() {
    user_marker.setPosition(NLatLng(position.latitude, position.longitude));
  }

  void _moveCameraTo() {
    _mapController.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(position.latitude, position.longitude), zoom: 15,));
  }
}