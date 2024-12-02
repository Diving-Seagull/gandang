import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gandang/data/model/search_content.dart';
import 'package:gandang/data/model/searched_info.dart';
import 'package:gandang/data/model/token_dto.dart';
import 'package:gandang/data/provider/login_notifier.dart';
import 'package:gandang/view/global/path_paint.dart';
import 'package:gandang/view/main/search_result_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/member.dart';
import '../../data/provider/route_provider.dart';
import '../global/color_data.dart';
import '../global/custom_appbar.dart';
import '../global/device_size.dart';
import '../global/no_animation_route.dart';

class MyPageView extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MemberInfoView();

}

class _MemberInfoView extends ConsumerState<MyPageView> {

  late double _deviceWidth, _deviceHeight;

  @override
  void initState() {
    super.initState();
  }

  final loginProvider = FutureProvider<Member?>((ref) async {
    var prefer = await SharedPreferences.getInstance();
    var tokenDto = TokenDto(prefer.getString('jwtToken')!);
    final repository = ref.read(loginRepositoryProvider);
    return await repository.getMember(tokenDto);
  });

  final starProvider = FutureProvider<List<SearchContent>?>((ref) async {
    var prefer = await SharedPreferences.getInstance();
    var tokenDto = TokenDto(prefer.getString('jwtToken')!);
    final repository = ref.read(routeRepositoryProvider);
    return await repository.getStarredRoutes(tokenDto);
  });

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: CustomAppBar.getTitleBar(context, '프로필'),
        body: SafeArea(
            child: Column(
          children: [
            _profileSection(),
          ],
        )));
  }

  Widget _profileSection() {
    var loginRef = ref.watch(loginProvider);
    return loginRef.when(data: (data){
      return Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Container(
                padding: EdgeInsets.only(top: 24, left: 30, bottom: 18),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: data!.profile_image == null ? CircleAvatar() : Image.network(data.profile_image!,
                                width: 80, height: 80, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.name, style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: ColorData.PRIMARY_COLOR
                          )),
                          const SizedBox(height: 8),
                          const Text('Description\nDescription', style: TextStyle(
                            fontSize: 16,
                            color: ColorData.CONTENTS_200
                          ))
                        ],
                      ),
                    ]
                )
            ),
              Container(
                  width: _deviceWidth,
                  margin: EdgeInsets.only(left: 18, right: 18),
                  decoration: BoxDecoration(
                    border: Border.all(color: ColorData.CONTENTS_050),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                      child: Text('프로필 수정', style: TextStyle(
                        fontSize: 16,
                        color: ColorData.COLOR_BLACK
                      )),
                      onPressed: () {})),
              SizedBox(height: 25),
              Container(height: 8, color: ColorData.CONTENTS_050),
                Container(padding: EdgeInsets.only(top: 40, left: 15, bottom: 20), child: const Text('즐겨찾기', style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700
                ))),
                _starredSection()
            ]
          )
      );
    }, error: (error, stack){
      print(error);
      return Center(child: Text('에러 발생'));
    }, loading: (){
      return Center(child: CircularProgressIndicator(color: ColorData.PRIMARY_COLOR));
    });
  }

  Widget _starredSection() {
    var starRef = ref.watch(starProvider);
    return starRef.when(data: (data){
      return Expanded(child: ListView.builder(
          itemCount: data!.length,
          itemBuilder: (context, index) {
            return Container(height: 90, padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15), child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(flex: 1, child: PathPaint.instance.getPathWidget(10)),
                    Expanded(flex: 5, child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data[index].start_name, style: TextStyle(
                          overflow: TextOverflow.ellipsis
                        ),),
                        Text(data[index].end_name, style: TextStyle(
                          overflow: TextOverflow.ellipsis
                        ),),
                      ],
                    )),
                    Expanded(flex: 1, child: IconButton(onPressed: (){
                      Navigator.push(
                          context,
                          NoAnimationRoute(pageBuilder: PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => SearchResultView(
                                SearchedInfo(data[index].start_address, data[index].start_latitude, data[index].start_longitude,
                                    data[index].end_address, data[index].end_latitude, data[index].end_longitude,
                                    data[index].start_name, data[index].end_name)),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: const Duration(microseconds: 300),
                          ).pageBuilder)
                      );
                    }, icon: SvgPicture.asset('assets/images/star-navi.svg')))
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: ColorData.CONTENTS_050)
              ],
            ));
          }));
    }, error: (error, stack){
      return Center(child: Text('오류 발생'));
    }, loading: (){
      return Center(child: CircularProgressIndicator(color: ColorData.PRIMARY_COLOR));
    });
  }
}
