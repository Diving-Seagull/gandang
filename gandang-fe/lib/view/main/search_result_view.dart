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

class _SearchResultView extends ConsumerState<SearchResultView> with SingleTickerProviderStateMixin {
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  final TextEditingController startController = TextEditingController(),
      finishController = TextEditingController();
  final PlaceViewModel _placeViewModel = PlaceViewModel();
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
    NLatLng(33.25189614312923, 126.19541555867804),
    NLatLng(33.25208888829063, 126.1952336626032),
    NLatLng(33.25263595966266, 126.19490281230006),
    NLatLng(33.2531249, 126.1945944),
    NLatLng(33.2533009, 126.1944374),
    NLatLng(33.25338282959337, 126.19434929592224),
    NLatLng(33.2540675, 126.193622),
    NLatLng(33.2541566, 126.19353),
    NLatLng(33.2543272, 126.1933464),
    NLatLng(33.2546063, 126.1930218),
    NLatLng(33.254676811260694, 126.1929268644732),
    NLatLng(33.25487395132104, 126.19257993362854),
    NLatLng(33.25510308960951, 126.19211191963353),
    NLatLng(33.2552895, 126.1916768),
    NLatLng(33.255652, 126.1909019),
    NLatLng(33.25567135939643, 126.19086043519346),
    NLatLng(33.25583901401168, 126.19056014676654),
    NLatLng(33.256163708373194, 126.18999058076571),
    NLatLng(33.25651365197978, 126.18937599249996),
    NLatLng(33.256622033763676, 126.18914358930064),
    NLatLng(33.2568403, 126.1886756),
    NLatLng(33.2570246, 126.1881341),
    NLatLng(33.25714021207365, 126.18785830252311),
    NLatLng(33.25727116588624, 126.18754590668102),
    NLatLng(33.257819169558545, 126.18639003133597),
    NLatLng(33.2580951, 126.1859433),
    NLatLng(33.2583445, 126.1853876),
    NLatLng(33.25850311255031, 126.18510802566638),
    NLatLng(33.2589948, 126.1844851),
    NLatLng(33.2590905, 126.1843438),
    NLatLng(33.2592978, 126.1839558),
    NLatLng(33.259470541046106, 126.18379082851813),
    NLatLng(33.26000393628587, 126.1832133611674),
    NLatLng(33.2605101, 126.1826731),
    NLatLng(33.2605941, 126.1826181),
    NLatLng(33.26062107705835, 126.18260042875335),
    NLatLng(33.26119366310708, 126.18227082818137)
  ];

  late NOverlayImage _customLocImage, orangeBicycleImg, orangeMarker, greenMarker;
  late NaverMapController _mapController;
  late SearchedInfo info;
  late NMarker user_marker;
  late Position position;

  StreamSubscription<Position>? _positionStream;
  int _selectedIndex = 0;
  bool isStartChecked = false;
  Color selectedColor = ColorData.PRIMARY_COLOR;
  List<NLatLng> startBicycleRoadData = [], endBicycleRoadData = [];
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startController.text = (info.start_text ?? '');
      finishController.text = (info.end_text ?? '');
      _startListeningToLocationChanges();
    });
  }

  void _onTabPressed(int index) {
    setState(() {
      _selectedIndex = index;
      if(_selectedIndex == 0) {
        selectedColor = ColorData.PRIMARY_COLOR;
        isStartChecked = false;
        getRecentRideLoc();
      }
      else {
        selectedColor = ColorData.PRI_SEC;
        isStartChecked = true;
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
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
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
                          )),
                        _destDetailSection()
                      ],
                    )
                  )
                ]
            )
        )
    );
  }

  Widget _destDetailSection() {
    return endBicycleRoadData.isEmpty ? Container(width: DeviceSize.getWidth(context), height: 175) : Container(
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
              Text('1시간 2분',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    color: selectedColor
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
              height: 40,
              decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextButton(
                onPressed: () async {
                  if(!isStartChecked) {
                    setState(() {
                      isStartChecked = true;
                    });
                    int target = (endBicycleRoadData.length / 2).toInt();
                    await _mapController.updateCamera(
                      NCameraUpdate.fromCameraPosition(
                        NCameraPosition(
                          target: endBicycleRoadData.elementAt(target),
                          zoom: 13,
                          tilt: 0, // 3D 효과를 위한 틸트 각도
                          bearing: 0, // 방향 (0~360°)
                        ),
                      ),
                    );
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

  // 자전거 경로 읽어오기
  void getRecentRideLoc() async {
    if(startBicycleRoadData.isEmpty || endBicycleRoadData.isEmpty) {
      await setNowLocation(false).then((onValue) async {
        var prefer = await SharedPreferences.getInstance();
        var token = prefer.getString('jwtToken')!;
        var startBicycleLoc =
        await _placeViewModel.getBicycleStation(position.latitude, position.longitude, TokenDto(token));
        var endBicycleLoc =
        await _placeViewModel.getBicycleStation(info.end_latitude, info.end_longitude, TokenDto(token));
        if(startBicycleLoc != null && endBicycleLoc != null) {
          clearMapOverlay();
          RoadSearchInfo startInfo =
          RoadSearchInfo(startName: base64Encode(utf8.encode('a')), startX: position.longitude, startY: position.latitude,
              endName: base64Encode(utf8.encode(startBicycleLoc.address)), endX: startBicycleLoc.longitude, endY: startBicycleLoc.latitude);
          var startRoadData = await _placeViewModel.getWalkingRoute(startInfo);
          startBicycleRoadData.addAll(startRoadData);
          RoadSearchInfo endInfo =
          RoadSearchInfo(startName: base64Encode(utf8.encode(endBicycleLoc.address)), startX: endBicycleLoc.longitude, startY: endBicycleLoc.latitude,
              endName: base64Encode(utf8.encode(info.end_address)), endX: info.end_longitude, endY: info.end_latitude);
          var endRoadData = await _placeViewModel.getWalkingRoute(endInfo);
          setState(() {
            this.endBicycleRoadData.addAll(endRoadData);
          });
          _mapController.addOverlay(NPathOverlay(id: 'bicycle-start', width: 6, coords: startRoadData, color: ColorData.PRIMARY_COLOR));
          _mapController.addOverlay(NPathOverlay(id: 'bicycle-end', width: 6, coords: endRoadData, color: ColorData.PRIMARY_COLOR));

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
        }
      });
    }
    int target = (startBicycleRoadData.length / 2).toInt();
    await _mapController.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: startBicycleRoadData.elementAt(target),
          zoom: 13,
          tilt: 0, // 3D 효과를 위한 틸트 각도
          bearing: 0, // 방향 (0~360°)
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
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

  void clearMapOverlay(){
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'start-loc'));
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'end-loc'));

    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-start-loc'));
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-end-loc'));
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-start'));
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-between'));
    _mapController.deleteOverlay(const NOverlayInfo(type: NOverlayType.pathOverlay, id: 'bicycle-end'));
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