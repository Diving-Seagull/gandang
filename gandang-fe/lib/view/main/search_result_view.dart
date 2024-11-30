import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gandang/data/model/road_search_info.dart';
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
  late NOverlayImage _customLocImage, orangeBicycleImg, orangeMarker, greenMarker;
  StreamSubscription<Position>? _positionStream;
  late NaverMapController _mapController;
  late NMarker user_marker, end_marker;
  late Position position;
  final TextEditingController startController = TextEditingController(),
      finishController = TextEditingController();
  final PlaceViewModel _placeViewModel = PlaceViewModel();
  late SearchedInfo info;
  final List<NLatLng> tmpPath = [
  NLatLng(33.2207094, 126.2492983),
  NLatLng(33.2214586, 126.2487727),
  NLatLng(33.222148939514504, 126.24828854310917),
  NLatLng(33.22264026281023, 126.24799288921156),
  NLatLng(33.2228993, 126.2478537),
  NLatLng(33.2233532, 126.2476584),
  NLatLng(33.223376845746394, 126.24764932848278),
  NLatLng(33.22431750671386, 126.24735415913877),
  NLatLng(33.22434477146041, 126.24734747660284),
  NLatLng(33.2249452, 126.2472894),
  NLatLng(33.2254545, 126.2472109),
  NLatLng(33.2257384, 126.2472589),
  NLatLng(33.2257983, 126.2469157),
  NLatLng(33.22588662414015, 126.246772078197),
  NLatLng(33.226121833617384, 126.24640943146088),
  NLatLng(33.2263922, 126.2459883),
  NLatLng(33.2266709, 126.2455672),
  NLatLng(33.22679284231388, 126.24538496679445),
  NLatLng(33.22720980695689, 126.24477565556666),
  NLatLng(33.227238562944684, 126.24472305314997),
  NLatLng(33.227825, 126.243842),
  NLatLng(33.22792, 126.24368),
  NLatLng(33.2280883, 126.2433592),
  NLatLng(33.22818954779813, 126.24316205400083),
  NLatLng(33.2284194240498, 126.24266421876958),
  NLatLng(33.22848738136104, 126.24251614472352),
  NLatLng(33.228894972749245, 126.24162543464121),
  NLatLng(33.2289442, 126.2415126),
  NLatLng(33.2293029, 126.2408933),
  NLatLng(33.2294888, 126.2405946),
  NLatLng(33.22957377993258, 126.2404608399374),
  NLatLng(33.230060987086944, 126.23971101594995),
  NLatLng(33.230367393395724, 126.23937707346278),
  NLatLng(33.23065127578348, 126.23913996746029),
  NLatLng(33.2308586, 126.2389696),
  NLatLng(33.2314072, 126.2385443),
  NLatLng(33.231461857303806, 126.2385019459481),
  NLatLng(33.23156177591745, 126.23842361691462),
  NLatLng(33.23180160779999, 126.23822978187388),
  NLatLng(33.23204143968252, 126.23803594683315),
  NLatLng(33.23282778341955, 126.23736107340743),
  NLatLng(33.23339638193053, 126.23687937421658),
  NLatLng(33.2337978964868, 126.23658899766093),
  NLatLng(33.23410357333583, 126.2364306020024),
  NLatLng(33.23444325562107, 126.23626737089344),
  NLatLng(33.2349138, 126.2360433),
  NLatLng(33.2353243, 126.2358509),
  NLatLng(33.235376850010674, 126.23582750511396),
  NLatLng(33.235463347720504, 126.2357889969569),
  NLatLng(33.235549845430334, 126.23575048879984),
  NLatLng(33.235636343140165, 126.23571198064276),
  NLatLng(33.23572284085, 126.2356734724857),
  NLatLng(33.23580933855983, 126.23563496432864),
  NLatLng(33.23589583626966, 126.23559645617158),
  NLatLng(33.237156244839056, 126.2350042212594),
  NLatLng(33.238826, 126.2342189),
  NLatLng(33.2395627, 126.2338696),
  NLatLng(33.2396967, 126.2338308),
  NLatLng(33.23977297345633, 126.2338087102402),
  NLatLng(33.2404104, 126.2334443),
  NLatLng(33.2407043, 126.2332259),
  NLatLng(33.240936999653364, 126.23299345943241),
  NLatLng(33.241275897895505, 126.23254462867611),
  NLatLng(33.241597, 126.2317917),
  NLatLng(33.2416461, 126.2316368),
  NLatLng(33.24169995231597, 126.23145076188938),
  NLatLng(33.24182522889568, 126.23091240613742),
  NLatLng(33.241990857455875, 126.23021920526406),
  NLatLng(33.24218089315133, 126.22962691747975),
  NLatLng(33.242421647652705, 126.22906466662072),
  NLatLng(33.2427572, 126.2284663),
  NLatLng(33.2428159, 126.2283704),
  NLatLng(33.2429779, 126.2281055),
  NLatLng(33.2430912, 126.2279026),
  NLatLng(33.2430097, 126.2278456),
  NLatLng(33.2427839, 126.2282316),
  NLatLng(33.2426804, 126.2284008),
  NLatLng(33.242514, 126.2286877),
  NLatLng(33.2422851, 126.2285831),
  NLatLng(33.24183129248574, 126.22877385977057),
  NLatLng(33.2413433, 126.2291173),
  NLatLng(33.241271, 126.2292606),
  NLatLng(33.24103270423949, 126.22914283759098),
  NLatLng(33.24061799121005, 126.22943209961572),
  NLatLng(33.24051077460193, 126.22985346389895),
  NLatLng(33.24029579642171, 126.23019622411357),
  NLatLng(33.23991868178187, 126.2307567550376),
  NLatLng(33.23982392938339, 126.23123990697358),
  NLatLng(33.23979600426885, 126.23152242191343),
  NLatLng(33.2398016432003, 126.23200876802231),
  NLatLng(33.23978691639857, 126.23264772348742),
  NLatLng(33.2398021, 126.2330943),
  NLatLng(33.2397811, 126.2337131),
  NLatLng(33.2395627, 126.2338696),
  NLatLng(33.2396967, 126.2338308),
  NLatLng(33.23977297345633, 126.2338087102402),
  NLatLng(33.2404104, 126.2334443),
  NLatLng(33.2407043, 126.2332259),
  NLatLng(33.240936999653364, 126.23299345943241),
  NLatLng(33.241275897895505, 126.23254462867611),
  NLatLng(33.241597, 126.2317917),
  NLatLng(33.2416461, 126.2316368),
  NLatLng(33.24169995231597, 126.23145076188938),
  NLatLng(33.24182522889568, 126.23091240613742),
  NLatLng(33.241990857455875, 126.23021920526406),
  NLatLng(33.24218089315133, 126.22962691747975),
  NLatLng(33.242421647652705, 126.22906466662072),
  NLatLng(33.2427572, 126.2284663),
  NLatLng(33.2428159, 126.2283704),
  NLatLng(33.2429779, 126.2281055),
  NLatLng(33.2430912, 126.2279026),
  NLatLng(33.2430097, 126.2278456),
  NLatLng(33.2425309, 126.2281444),
  NLatLng(33.2423755, 126.2281493),
  NLatLng(33.24242695284457, 126.22774850611297),
  NLatLng(33.242468578720676, 126.22761117505576),
  NLatLng(33.24259319941426, 126.22713737692162),
  NLatLng(33.24289633508487, 126.22630714029609),
  NLatLng(33.24310925166969, 126.22580163804052),
  NLatLng(33.2431366, 126.2250368),
  NLatLng(33.2431426, 126.2250154),
  NLatLng(33.242523908982875, 126.22454639514105),
  NLatLng(33.24191126741782, 126.22455003933892),
  NLatLng(33.241638843593556, 126.22435799125317),
  NLatLng(33.241443174628984, 126.22389392917317),
  NLatLng(33.24131594514502, 126.22323312718639),
  NLatLng(33.24148215902055, 126.22277994581631),
  NLatLng(33.24171129721287, 126.22238600160395),
  NLatLng(33.24192998093512, 126.22205752989623),
  NLatLng(33.242314460500815, 126.22154692442312),
  NLatLng(33.2428053, 126.2209188),
  NLatLng(33.2428649, 126.2208263),
  NLatLng(33.2431963, 126.2202927),
  NLatLng(33.2433343, 126.2200686),
  NLatLng(33.24346703720118, 126.21974007269677),
  NLatLng(33.243584841750376, 126.21923449740054),
  NLatLng(33.2436179, 126.218695),
  NLatLng(33.2436179, 126.2181746),
  NLatLng(33.24361412008379, 126.21795918183429),
  NLatLng(33.24360587594255, 126.21717488393696),
  NLatLng(33.2436655, 126.2165525),
  NLatLng(33.2437184, 126.2161237),
  NLatLng(33.24375038164667, 126.21576447066155),
  NLatLng(33.243686736466444, 126.21544613110402),
  NLatLng(33.24357164849295, 126.21495256445324),
  NLatLng(33.24344816734413, 126.21423656985782),
  NLatLng(33.243365013853875, 126.2137403957737),
  NLatLng(33.24321831611529, 126.21318104676912),
  NLatLng(33.2431283, 126.2124423),
  NLatLng(33.2431495, 126.212232),
  NLatLng(33.24317195382415, 126.21203794789017),
  NLatLng(33.243250133452484, 126.21155614778172),
  NLatLng(33.24339413440321, 126.21102203066633),
  NLatLng(33.24358633504264, 126.21046667707624),
  NLatLng(33.24383077396806, 126.21001614338921),
  NLatLng(33.244107042206686, 126.20958628064595),
  NLatLng(33.24446063028892, 126.20908620217017),
  NLatLng(33.24463210844724, 126.20864406044547),
  NLatLng(33.24470439780824, 126.20844973758764),
  NLatLng(33.24477972286012, 126.20824470456543),
  NLatLng(33.245097, 126.2072304),
  NLatLng(33.2452772, 126.2067019),
  NLatLng(33.24529544872412, 126.2066286023343),
  NLatLng(33.245556, 126.2055229),
  NLatLng(33.2455639, 126.2054532),
  NLatLng(33.2455679, 126.2052682),
  NLatLng(33.24557993997612, 126.20496095765222),
  NLatLng(33.24574826284036, 126.20448863890265),
  NLatLng(33.24608195932154, 126.20391276484773),
  NLatLng(33.246261849394045, 126.2034728717468),
  NLatLng(33.2464774, 126.2029901),
  NLatLng(33.2466967, 126.2026461),
  NLatLng(33.24683514462118, 126.20242820036547),
  NLatLng(33.2472152, 126.201807),
  NLatLng(33.2474635, 126.201406),
  NLatLng(33.24755041713079, 126.2012778040511),
  NLatLng(33.247783042043, 126.20097639746238),
  NLatLng(33.2479224, 126.2008354),
  NLatLng(33.2485131, 126.2002906),
  NLatLng(33.248644146224365, 126.20015182158252),
  NLatLng(33.248955572711864, 126.19977473966698),
  NLatLng(33.24925215192862, 126.19939719868482),
  NLatLng(33.2499998, 126.1983758),
  NLatLng(33.250018, 126.1983425),
  NLatLng(33.250066621623645, 126.19825349010867),
  NLatLng(33.250325928119025, 126.19780075031045),
  NLatLng(33.250610292692365, 126.19728067398115),
  NLatLng(33.25079633164811, 126.1968588663023),
  NLatLng(33.25109667255892, 126.19638939631267),
  NLatLng(33.2516181, 126.1956926),
  NLatLng(33.2517248, 126.1955863),
  NLatLng(33.25189614312923, 126.19541)
  ];
  int _selectedIndex = 0;
  _SearchResultView(this.info);

  @override
  void initState() {
    super.initState();
    _customLocImage = const NOverlayImage.fromAssetImage('assets/images/orange-now.png');
    orangeBicycleImg = const NOverlayImage.fromAssetImage('assets/images/orange-dest-logo.png');
    orangeMarker = const NOverlayImage.fromAssetImage('assets/images/orange-marker.png');
    greenMarker = const NOverlayImage.fromAssetImage('assets/images/green-marker.png');
    user_marker = NMarker(id: 'userLoc',
        position: NLatLng(0, 0),
        icon: _customLocImage,
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
    });
  }

  Future<void> setNowLocation(bool isMap) async {
    await Geolocator.getCurrentPosition().then((value){
      position = value;
      if(isMap) {
        _addMarker();
      }
    });
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
                    child: Container(

                    ),
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
      ),
      onMapReady: (controller) async {
        _mapController = controller;
        _mapController.addOverlay(user_marker);
        _mapController.addOverlay(NPathOverlay(id: 'id', coords: tmpPath, color: Colors.green));
        mapControllerCompleter.complete(controller);  // Completer에 지도 컨트롤러 완료 신호 전송
        print("onMapReady");
        await setNowLocation(true);
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
          target: NLatLng(position.latitude, position.longitude), zoom: 15));
  }

  void getRecentRideLoc() async {
    await setNowLocation(false).then((onValue) async {
      _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'start-loc'));
      _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'end-loc'));
      var prefer = await SharedPreferences.getInstance();
      var token = prefer.getString('jwtToken')!;
        if(_selectedIndex == 0) {
          var startBicycleLoc =
          await _placeViewModel.getBicycleStation(position.latitude, position.longitude, TokenDto(token));
          var endBicycleLoc =
          await _placeViewModel.getBicycleStation(info.end_latitude, info.end_longitude, TokenDto(token));
          if(startBicycleLoc != null && endBicycleLoc != null) {
            _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-start-loc'));
            _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-end-loc'));
            _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-start'));
            _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-between'));
            _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-end'));

          RoadSearchInfo startInfo =
            RoadSearchInfo(startName: base64Encode(utf8.encode('a')), startX: position.longitude, startY: position.latitude,
                endName: base64Encode(utf8.encode(startBicycleLoc.address)), endX: startBicycleLoc.longitude, endY: startBicycleLoc.latitude);
          var startRoadData = await _placeViewModel.getWalkingRoute(startInfo);
          RoadSearchInfo endInfo =
          RoadSearchInfo(startName: base64Encode(utf8.encode(endBicycleLoc.address)), startX: endBicycleLoc.longitude, startY: endBicycleLoc.latitude,
              endName: base64Encode(utf8.encode(info.end_address)), endX: info.end_longitude, endY: info.end_latitude);
          var endRoadData = await _placeViewModel.getWalkingRoute(endInfo);

          _mapController.addOverlay(NPathOverlay(id: 'bicycle-start', width: 6, coords: startRoadData, color: ColorData.CONTENTS_050));
          _mapController.addOverlay(NPathOverlay(id: 'bicycle-end', width: 6, coords: endRoadData, color: ColorData.CONTENTS_300));

          //TODO :: 백엔드에서 해안도로 경로 받아와야 함
          List<NLatLng> rideList = [
            startRoadData.last,
            endRoadData.first
          ];
          _mapController.addOverlay(NPathOverlay(id: 'bicycle-between', width: 6, coords: rideList, color: ColorData.PRIMARY_COLOR));
            _mapController.addOverlay(
                NMarker(
                    id: 'start-loc',
                    icon: orangeMarker,
                    size: Size(38, 46),
                    position: NLatLng(position.latitude, position.longitude,
                    )));
            _mapController.addOverlay(
                NMarker(
                    id: 'end-loc',
                    icon: orangeMarker,
                    size: Size(38, 46),
                    position: NLatLng(info.end_latitude, info.end_longitude,
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
        }
      }
    });
  }

  // 경로 안내
  void trackingMap(List<NLatLng> roadData) async {
    for(var tmp in roadData) {
      user_marker.setPosition(tmp);
      await _mapController.updateCamera(
        NCameraUpdate.fromCameraPosition(
          NCameraPosition(
            target: tmp,
            zoom: 18,
            tilt: 0, // 3D 효과를 위한 틸트 각도
            bearing: 0, // 방향 (0~360°)
          ),
        ),
      );
      await Future.delayed(Duration(seconds: 1));
    }
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