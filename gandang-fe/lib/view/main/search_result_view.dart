import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gandang/data/model/searched_info.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/global/location_service.dart';
import '../../data/model/token_dto.dart';
import '../../viewmodel/place_viewmodel.dart';
import '../global/color_data.dart';
import '../global/device_size.dart';
import '../global/path_paint.dart';

class SearchResultView extends ConsumerStatefulWidget {
  final SearchedInfo info;
  const SearchResultView(this.info, {super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchResultView(info);
}

class _SearchResultView extends ConsumerState<SearchResultView>
    with SingleTickerProviderStateMixin {
  // NaverMapController 객체의 비동기 작업 완료를 나타내는 Completer 생성
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  late NOverlayImage _customLocImage;
  StreamSubscription<Position>? _positionStream;
  late NaverMapController _mapController;
  late NMarker user_marker, end_marker;
  late Position position;
  final TextEditingController startController = TextEditingController(),
      finishController = TextEditingController();
  final PlaceViewModel _placeViewModel = PlaceViewModel();
  final SearchedInfo info;
  final List<NLatLng> tmpPath = [
    NLatLng(33.4611246,126.9333801),
    NLatLng(33.4610729,126.9332102),
    NLatLng(33.4605147,126.9314692),
    NLatLng(33.460435,126.9312585),
    NLatLng(33.4605423,126.931127),
    NLatLng(33.460435,126.9312585),
    NLatLng(33.4605147,126.9314692),
    NLatLng(33.460435,126.9312585),
    NLatLng(33.4601885,126.9307837),
    NLatLng(33.4590359,126.9294882),
    NLatLng(33.4590712,126.9290206),
    NLatLng(33.4587719,126.9289979),
    NLatLng(33.4587924,126.9293385),
    NLatLng(33.4590359,126.9294882),
    NLatLng(33.4587924,126.9293385),
    NLatLng(33.4587719,126.9289979),
    NLatLng(33.4587924,126.9293385),
    NLatLng(33.4587719,126.9289979),
    NLatLng(33.4583679,126.9289286),
    NLatLng(33.4501722,126.9208439),
    NLatLng(33.4497759,126.9203852),
    NLatLng(33.4494062,126.9199687),
    NLatLng(33.4489827,126.9198172),
    NLatLng(33.4469509,126.9184896),
    NLatLng(33.4389449,126.9196117),
    NLatLng(33.4378593,126.9197987),
    NLatLng(33.4370326,126.9196522),
    NLatLng(33.436403,126.9193495),
    NLatLng(33.4357634,126.9189606),
    NLatLng(33.4352315,126.9166193),
    NLatLng(33.43407,126.9159127),
    NLatLng(33.4352315,126.9166193),
    NLatLng(33.4357634,126.9189606),
    NLatLng(33.436403,126.9193495),
    NLatLng(33.4366413,126.9212688),
    NLatLng(33.4364162,126.922448),
    NLatLng(33.4337967,126.9246813),
    NLatLng(33.4364162,126.922448),
    NLatLng(33.4366413,126.9212688),
    NLatLng(33.436403,126.9193495),
    NLatLng(33.4357634,126.9189606),
    NLatLng(33.4352315,126.9166193),
    NLatLng(33.43407,126.9159127),
    NLatLng(33.4325174,126.9152276),
    NLatLng(33.4267513,126.9160379),
    NLatLng(33.4325174,126.9152276),
    NLatLng(33.43407,126.9159127),
    NLatLng(33.4352315,126.9166193),
    NLatLng(33.4357634,126.9189606),
    NLatLng(33.436403,126.9193495),
    NLatLng(33.4366413,126.9212688),
    NLatLng(33.4364162,126.922448),
    NLatLng(33.4337967,126.9246813),
    NLatLng(33.4248533,126.9266641)
  ];
  int _selectedIndex = 0;
  _SearchResultView(this.info);

  @override
  void initState() {
    super.initState();
    _customLocImage = const NOverlayImage.fromAssetImage('assets/images/orange-now.png');
    user_marker = NMarker(id: 'userLoc',
        position: NLatLng(0, 0),
        icon: _customLocImage
    );
    end_marker = NMarker(id: 'user_dest',
        position: NLatLng(0, 0));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startController.text = (info.start_text ?? '');
      finishController.text = (info.end_text ?? '');
      _startListeningToLocationChanges();
    });
  }

  void _onTabPressed(int index) {
    setState(() {
      _selectedIndex = index;
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

  Future<void> setNowLocation(bool isMap) async {
    position = await Geolocator.getCurrentPosition();
    if(isMap) {
      _addMarker();
    }
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
                        _setSearch(),
                        _setTypeTab(),
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
                                      setNowLocation(true);
                                      _addMarker();
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text('data'),
                  )
                ]
            )
        )
    );
  }

  Widget _setTypeTab() {
    return Container(
        width: DeviceSize.getWidth(context),
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        decoration: BoxDecoration(
        color: ColorData.CONTENTS_050, // 전체 배경 색상
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4), // 내부 여백
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // 첫 번째 탭 버튼 (자전거)
          Flexible(child: _buildTabButton(
            index: 0,
            label: '자전거',
            icon: Icons.pedal_bike,
            isSelected: _selectedIndex == 0,
            selectedColor: Colors.orange[100]!,
            unselectedColor: Colors.transparent,
          )),
          // 두 번째 탭 버튼 (자동차)
          Flexible(child: _buildTabButton(
            index: 1,
            label: '자동차',
            icon: Icons.directions_car,
            isSelected: _selectedIndex == 1,
            selectedColor: Colors.green[100]!,
            unselectedColor: Colors.transparent,
          )),
        ],
      )
    );
  }

  Widget _naverMap() {
    return NaverMap(
      options: const NaverMapViewOptions(
        indoorEnable: false,             // 실내 맵 사용 가능 여부 설정
        locationButtonEnable: false,    // 위치 버튼 표시 여부 설정
        consumeSymbolTapEvents: false,  // 심볼 탭 이벤트 소비 여부 설정
        mapType: NMapType.navi
      ),
      onMapReady: (controller) async {
        _mapController = controller;
        _mapController.addOverlay(user_marker);
        _mapController.addOverlay(NPathOverlay(id: 'id', coords: tmpPath));
        mapControllerCompleter.complete(controller);  // Completer에 지도 컨트롤러 완료 신호 전송
        print("onMapReady");
        setNowLocation(true);
        getRecentRideLoc();
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

  void getRecentRideLoc() async {
    await setNowLocation(false).then((onValue) async {
      var prefer = await SharedPreferences.getInstance();
      var token = prefer.getString('jwtToken')!;
      var startLoc =
          await _placeViewModel.getBicycleStation(position.latitude, position.longitude, TokenDto(token));
      var endLoc =
          await _placeViewModel.getBicycleStation(info.end_latitude, info.end_longitude, TokenDto(token));
      if(startLoc != null && endLoc != null) {
        print('호출 완료');
        if(_selectedIndex == 0) {
          var _destImage = const NOverlayImage.fromAssetImage('assets/images/orange-dest-logo.png');
          _mapController.addOverlay(
              NMarker(
                  id: 'bicycle-dest',
                  icon: _destImage,
                  position: NLatLng(info.end_latitude, info.end_longitude,
                  )));
        }
      }
    });
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
              _searchPath();
            });
          },
              icon: SvgPicture.asset('assets/images/cross-direction.svg')),
        ),
        Flexible(
          child: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: SvgPicture.asset('assets/images/delete-logo.svg')),
        ),
      ],
    );
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

    } catch(e) {
      print(e);
    }
  }


  // 커스텀 탭 버튼
  Widget _buildTabButton({
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    return GestureDetector(
      onTap: () => _onTabPressed(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor, // 선택된 탭에 색상 추가
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey, // 선택된 탭에 아이콘 색상 변경
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.grey, // 선택된 탭에 글자 색상 변경
              ),
            ),
          ],
        ),
      ),
    );
  }
}