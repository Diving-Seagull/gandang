import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gandang/data/model/path_dto.dart';
import 'package:gandang/data/model/road_search_info.dart';
import 'package:gandang/data/model/route_req.dart';
import 'package:gandang/data/model/routes_dto.dart';
import 'package:gandang/data/model/searched_info.dart';
import 'package:gandang/view/global/convert_time.dart';
import 'package:gandang/view/main/spot_view.dart';
import 'package:gandang/viewmodel/route_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/global/location_service.dart';
import '../../data/model/token_dto.dart';
import '../../viewmodel/place_viewmodel.dart';
import '../global/color_data.dart';
import '../global/device_size.dart';
import '../global/gps_locate.dart';
import '../global/no_animation_route.dart';
import '../global/path_paint.dart';

class SearchResultView extends ConsumerStatefulWidget {
  final SearchedInfo info;
  const SearchResultView(this.info, {super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchResultView(info);
}

class _SearchResultView extends ConsumerState<SearchResultView> with SingleTickerProviderStateMixin {
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  final TextEditingController startController = TextEditingController(),
      finishController = TextEditingController();
  final PlaceViewModel _placeViewModel = PlaceViewModel();
  final RouteViewModel _routeViewModel = RouteViewModel();


  late NOverlayImage _customLocImage, orangeBicycleImg, orangeMarker, greenMarker;
  late NaverMapController _mapController;
  late SearchedInfo info;
  late NMarker user_marker;
  late Position position;

  StreamSubscription<Position>? _positionStream;
  int _selectedIndex = 0;
  bool isStartChecked = false, isTrack = false;
  Color selectedColor = ColorData.PRIMARY_COLOR;
  List<NLatLng> bicycleRoadData = [], bicycleStartRoadData = [], bicycleEndRoadData = [], carRoadData = [];
  RoutesDto? resultLoc;
  PathDto? spotLoc;
  _SearchResultView(this.info);

  @override
  void initState() {
    super.initState();
    orangeBicycleImg = const NOverlayImage.fromAssetImage('assets/images/orange-dest-logo.png');
    orangeMarker = const NOverlayImage.fromAssetImage('assets/images/orange-marker.png');
    greenMarker = const NOverlayImage.fromAssetImage('assets/images/green-marker.png');
    user_marker = NMarker(id: 'userLoc',
        position: NLatLng(0, 0),
        icon: _selectedIndex == 0 ? const NOverlayImage.fromAssetImage('assets/images/orange-now.png') : const NOverlayImage.fromAssetImage('assets/images/green-now.png'),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startController.text = (info.start_text ?? '');
      finishController.text = (info.end_text ?? '');
      // _startListeningToLocationChanges();
    });
  }

  void _onTabPressed(int index) {
    setState(() {
      _selectedIndex = index;
      user_marker.setIcon(NOverlayImage.fromAssetImage('assets/images/orange-now.png'));
      if(_selectedIndex == 0) {
        carRoadData.clear();
        selectedColor = ColorData.PRIMARY_COLOR;
        isStartChecked = false;
        getRecentRideLoc();
      }
      else {
        user_marker.setIcon(NOverlayImage.fromAssetImage('assets/images/green-now.png'));
        bicycleRoadData.clear();
        selectedColor = ColorData.PRI_SEC;
        isStartChecked = true;
        getRecentCarLoc();
      }
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
    });
  }

  Future<void> setNowLocation(bool isMap) async {
    // await Geolocator.getCurrentPosition().then((value){
    //   GpsLocate.lat = value.latitude;
    //   GpsLocate.lng = value.longitude;
    //   if(isMap) {
    //     _addMarker();
    //   }
    // });
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
                        (!isTrack) ? _setTypeTab() : const SizedBox(),
                        (!isTrack) ? _destOptionSection() : const SizedBox(),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        (!isTrack) ? _destBottomSection() : const SizedBox(),
                        (!isTrack) ? _destDetailSection() : const SizedBox()
                      ],
                    )
                  )
                ]
            )
        )
    );
  }

  Widget _destOptionSection() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _destBottomSection() {
    return Align(
        alignment: Alignment.bottomRight,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Flexible(child: SizedBox(
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
        )
    );
  }

  Widget _destDetailSection() {
    return (bicycleRoadData.isEmpty && carRoadData.isEmpty) ? Container(width: DeviceSize.getWidth(context), height: 175) : Container(
      width: DeviceSize.getWidth(context),
      height: 175,
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 20),
      decoration: BoxDecoration(
          color: ColorData.COLOR_WHITE,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selectedColor),
          boxShadow: [
            BoxShadow(color: ColorData.COLOR_BLACK.withOpacity(0.5) ,
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
              Text('${ConvertTime.instance.convertDecimalToTime(resultLoc!.total_distance / (_selectedIndex == 0 ? 20 : 50))}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    color: selectedColor
                ),
              ),
              const SizedBox(width: 10),
              const Text('|', style: TextStyle(color: ColorData.CONTENTS_100)),
              const SizedBox(width: 10),
              Text("${resultLoc!.total_distance.toStringAsFixed(1)}km",
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
              height: 40,
              decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextButton(
                onPressed: () async {
                  if(_selectedIndex == 0) {
                    if(!isStartChecked) {
                      setState(() {
                        isStartChecked = true;
                      });
                      int target = (bicycleEndRoadData.length / 2).toInt();
                      await _mapController.updateCamera(
                        NCameraUpdate.fromCameraPosition(
                          NCameraPosition(
                            target: bicycleEndRoadData.elementAt(target),
                            zoom: 13,
                            tilt: 0, // 3D 효과를 위한 틸트 각도
                            bearing: 0, // 방향 (0~360°)
                          ),
                        ),
                      );
                    }
                    else {
                      trackingMap(bicycleRoadData);
                    }
                  }
                  else {
                    trackingMap(carRoadData);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, // 안쪽 여백 직접 조정
                ), child: Text(!isStartChecked ? '도착지 정류소 확인하기' : '경로 안내하기 >' ,
                style: const TextStyle(
                    color: ColorData.COLOR_WHITE,
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
              )
          )
        ],
      ),
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
            isSelected: _selectedIndex == 0,
            selectedColor: ColorData.SECONDARY_00,
            unselectedColor: Colors.transparent,
            selectedTextColor: ColorData.PRIMARY_COLOR,
          )),
          // 두 번째 탭 버튼 (자동차)
            Flexible(child: _buildTabButton(
            index: 1,
            label: '자동차',
            isSelected: _selectedIndex == 1,
            selectedColor: ColorData.PRI_SEC10,
            unselectedColor: Colors.transparent,
              selectedTextColor: ColorData.PRI_SEC
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
      ),
      onMapReady: (controller) async {
        _mapController = controller;
        _mapController.addOverlay(user_marker);
        mapControllerCompleter.complete(controller);  // Completer에 지도 컨트롤러 완료 신호 전송
        print("onMapReady");
        await setNowLocation(true);
        getRecentRideLoc();
      },
    );
  }

  void _addMarker() {
    user_marker.setPosition(NLatLng(GpsLocate.lat, GpsLocate.lng));
    _moveCameraTo();
  }

  void _moveCameraTo() {
    _mapController.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(GpsLocate.lat, GpsLocate.lng), zoom: 15));
  }

  // 자전거 경로 읽어오기
  void getRecentRideLoc() async {
    if(bicycleRoadData.isEmpty) {

      bicycleStartRoadData.clear();
      bicycleEndRoadData.clear();

      var prefer = await SharedPreferences.getInstance();
      var token = prefer.getString('jwtToken')!;
      var startBicycleLoc =
      await _placeViewModel.getBicycleStation(GpsLocate.lat, GpsLocate.lng, TokenDto(token));
      var endBicycleLoc =
      await _placeViewModel.getBicycleStation(info.end_latitude, info.end_longitude, TokenDto(token));
      clearMapOverlay();
      if(startBicycleLoc != null && endBicycleLoc != null) {
        List<NLatLng> startRoadData = [], endRoadData = [];
        try{
          RoadSearchInfo startInfo =
          RoadSearchInfo(startName: base64Encode(utf8.encode('a')), startX: GpsLocate.lng, startY: GpsLocate.lat,
              endName: base64Encode(utf8.encode(startBicycleLoc.address)), endX: startBicycleLoc.longitude, endY: startBicycleLoc.latitude);
          var tmpStart = await _placeViewModel.getWalkingRoute(startInfo);
          startRoadData.addAll(tmpStart);
          RoadSearchInfo endInfo =
          RoadSearchInfo(startName: base64Encode(utf8.encode(endBicycleLoc.address)), startX: endBicycleLoc.longitude, startY: endBicycleLoc.latitude,
              endName: base64Encode(utf8.encode(info.end_address)), endX: info.end_longitude, endY: info.end_latitude);
          var tmpEnd = await _placeViewModel.getWalkingRoute(endInfo);
          endRoadData.addAll(tmpEnd);
        } catch(e) {
          startRoadData.add(NLatLng(GpsLocate.lat, GpsLocate.lng));
          endRoadData.add(NLatLng(info.end_latitude, info.end_longitude));
        }

        bicycleRoadData.addAll(startRoadData);
        bicycleStartRoadData.addAll(startRoadData);

        //백엔드에서 해안도로 경로 받아와야 함
        var coast_req = RouteReq(
            startBicycleLoc.latitude, startBicycleLoc.longitude, info.start_address, info.start_text ?? info.start_address,
            endBicycleLoc.latitude, endBicycleLoc.longitude, info.end_address, info.end_text ?? info.end_address);
        var coastRoutes = await _routeViewModel.postRoutes(coast_req, TokenDto(token));
        if(coastRoutes != null) {
          // print(coastRoutes.toJson().toString());
          resultLoc = coastRoutes;
          spotLoc = coastRoutes.path.where((data) => data.type == 'tourspot').firstOrNull;
          var pathList =  coastRoutes.path.map((data) => NLatLng(data.lat, data.lng)).toList();
          pathList.insert(0, NLatLng(startRoadData.last.latitude, startRoadData.last.longitude));
          pathList.insert(pathList.length - 1, NLatLng(endRoadData.first.latitude, endRoadData.first.longitude));
          _mapController.addOverlay(NPathOverlay(id: 'bicycle-between', width: 6,
              coords: pathList, color: ColorData.PRIMARY_COLOR));
          bicycleRoadData.addAll(pathList);
        }
        _mapController.addOverlay(NPathOverlay(id: 'bicycle-start', width: 6, coords: startRoadData, color: ColorData.PRIMARY_COLOR));
        _mapController.addOverlay(NPathOverlay(id: 'bicycle-end', width: 6, coords: endRoadData, color: ColorData.PRIMARY_COLOR));
        
        if(spotLoc != null) {
          _mapController.addOverlay(
            NMarker(id: 'spot-loc', 
                position: NLatLng(spotLoc!.lat, spotLoc!.lng),
                size: const Size(38, 46),
                icon: orangeMarker,
                caption: NOverlayCaption(text: spotLoc!.name)
            )
          );
        }
        
        _mapController.addOverlay(
            NMarker(
                id: 'start-loc',
                icon: orangeMarker,
                size: const Size(38, 46),
                position: NLatLng(startRoadData[0].latitude, startRoadData[0].longitude,
                )));
        _mapController.addOverlay(
            NMarker(
                id: 'end-loc',
                icon: orangeMarker,
                size: const Size(38, 46),
                position: NLatLng(endRoadData.last.latitude, endRoadData.last.longitude,
                )));
        _mapController.addOverlay(
            NMarker(
                id: 'bicycle-start-loc',
                icon: orangeBicycleImg,
                position: NLatLng(startBicycleLoc.latitude, startBicycleLoc.longitude,
                )));
        _mapController.addOverlay(
            NMarker(
                id: 'bicycle-end-loc',
                icon: orangeBicycleImg,
                position: NLatLng(endBicycleLoc.latitude, endBicycleLoc.longitude,
                )));
        setState(() {
          bicycleEndRoadData.addAll(endRoadData);
          bicycleRoadData.addAll(endRoadData);
        });
      }
    }
    int target = (bicycleStartRoadData.length / 2).toInt();
    await _mapController.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: bicycleStartRoadData.elementAt(target),
          zoom: 13,
          tilt: 0, // 3D 효과를 위한 틸트 각도
          bearing: 0, // 방향 (0~360°)
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
  }

  void getRecentCarLoc() async {
    if(carRoadData.isEmpty) {
      var prefer = await SharedPreferences.getInstance();
      var token = prefer.getString('jwtToken')!;
      clearMapOverlay();
      //백엔드에서 해안도로 경로 받아와야 함
      var coast_req = RouteReq(
          info.start_latitude, info.start_longitude, info.start_address, info.start_text ?? info.start_address,
          info.end_latitude, info.end_longitude, info.end_address, info.end_text ?? info.end_address);

      var coastRoutes = await _routeViewModel.postRoutes(coast_req, TokenDto(token));
      if(coastRoutes != null) {
        // print(coastRoutes.toJson().toString());
        resultLoc = coastRoutes;
        spotLoc = coastRoutes.path.where((data) => data.type == 'tourspot').firstOrNull;
        var pathList =  coastRoutes.path.map((data) => NLatLng(data.lat, data.lng)).toList();
        _mapController.addOverlay(NPathOverlay(id: 'car-between', width: 6,
            coords: pathList, color: selectedColor));

        if(spotLoc != null) {
          _mapController.addOverlay(
              NMarker(id: 'spot-loc',
                  position: NLatLng(spotLoc!.lat, spotLoc!.lng),
                  size: const Size(38, 46),
                  icon: greenMarker,
                  caption: NOverlayCaption(text: spotLoc!.name)
              )
          );
        }

        _mapController.addOverlay(
            NMarker(
                id: 'start-loc',
                icon: greenMarker,
                size: const Size(38, 46),
                position: NLatLng(info.start_latitude, info.start_longitude,
                )));
        _mapController.addOverlay(
            NMarker(
                id: 'end-loc',
                icon: greenMarker,
                size: const Size(38, 46),
                position: NLatLng(info.end_latitude, info.end_longitude,
                )));

        setState(() {
          carRoadData.addAll(pathList);
        });
      }
    }
    int target = (carRoadData.length / 2).toInt();
    await _mapController.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: carRoadData.elementAt(target),
          zoom: 10,
          tilt: 0, // 3D 효과를 위한 틸트 각도
          bearing: 0, // 방향 (0~360°)
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
  }

  // 경로 안내
  void trackingMap(List<NLatLng> roadData) async {
    if(!isTrack) {
      setState(() {
        isTrack = true;
      });

      if(spotLoc != null) {
        Navigator.push(
            context,
            NoAnimationRoute(pageBuilder: PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => SpotView(_selectedIndex, spotLoc!.name),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: const Duration(microseconds: 300),
            ).pageBuilder)).then((onValue) async {
          for(var tmp in roadData) {
            user_marker.setPosition(tmp);
            _mapController.updateCamera(
              NCameraUpdate.fromCameraPosition(
                NCameraPosition(
                  target: tmp,
                  zoom: 18,
                  tilt: 0, // 3D 효과를 위한 틸트 각도
                  bearing: 0, // 방향 (0~360°)
                ),
              ),
            );
            await Future.delayed(const Duration(milliseconds: 50));
          }
          //메인 화면 이동
          await Future.delayed(const Duration(seconds: 1));
          Navigator.popUntil(context, (route) => route.isFirst);
        });
      }
      else {
        for(var tmp in roadData) {
          user_marker.setPosition(tmp);
          _mapController.updateCamera(
            NCameraUpdate.fromCameraPosition(
              NCameraPosition(
                target: tmp,
                zoom: 18,
                tilt: 0, // 3D 효과를 위한 틸트 각도
                bearing: 0, // 방향 (0~360°)
              ),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 50));
        }
        await Future.delayed(const Duration(seconds: 1));
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  void clearMapOverlay(){
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.marker, id: 'start-loc'));
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.marker, id: 'end-loc'));
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.marker, id: 'spot-loc'));
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.marker, id: 'bicycle-start-loc'));
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.marker, id: 'bicycle-end-loc'));

    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-start'));
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-between'));
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-end'));

    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'car-between'));
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
            readOnly: true
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
            readOnly: true,
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

      if(start_address != null && end_address != null) {
        info = SearchedInfo(
            start_address.address_name, start_address.x, start_address.y,
            end_address.address_name, end_address.x, end_address.y, start, finish);
        getRecentRideLoc();
      }
    } catch(e) {
      print(e);
    }
  }


  // 커스텀 탭 버튼
  Widget _buildTabButton({
    required int index,
    required String label,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
    required Color selectedTextColor
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected? FontWeight.bold : FontWeight.normal,
                color: isSelected ? selectedTextColor : ColorData.CONTENTS_200, // 선택된 탭에 글자 색상 변경
              ),
            ),
          ],
        ),
      ),
    );
  }
}