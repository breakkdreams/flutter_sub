import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/pages/searchBarDelegate.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/data_service.dart';
import '../widgets/staggeredGridView.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List categoryList = new List();
  List bannerList = new List();
  List goodsList = new List();
  List recommendList = new List();
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _showLoading = true;
    });
    _init();
  }

  void _init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid};
    String secret_open = prefs.getString('secret_open');
    if(secret_open == '1') {
      lock(formData).then((params){
        formData = {'data':params};
        request('home_banner_api', formData: formData).then((val) {
          var data = json.decode(val.toString());
          bannerList = data['data']['WEB'];
          _init2();
        });
      });
    }
  }
  void _init2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid};
    String secret_open = prefs.getString('secret_open');
    if(secret_open == '1') {
      lock(formData).then((params){
        formData = {'data':params};
        request('home_category_api', formData: formData).then((val) {
          var data = json.decode(val.toString());
          categoryList = data['data']['WEB'];
          _init3();
        });
      });
    }
  }

  void _init3() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid};
    String secret_open = prefs.getString('secret_open');
    if(secret_open == '1') {
      lock(formData).then((params){
        formData = {'data':params};
        request('home_goods_api', formData: formData).then((val) {
          var data = json.decode(val.toString());
          delock(data['data']).then((unlock_data){
            data['data'] = json.decode(unlock_data.toString());
            goodsList = data['data']['data'];
            _init4();
          });

        });
      });
    }
  }

  void _init4() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid};
    String secret_open = prefs.getString('secret_open');
    if(secret_open == '1') {
      lock(formData).then((params){
        formData = {'data':params};
        request('home_recommend_api', formData: formData).then((val) {
          var data = json.decode(val.toString());
          recommendList = data['data']['WEB'];
          setState(() {
            _showLoading = false;
          });
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('首页'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search,color: Colors.white,),
              onPressed: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchGoodsPage()));
              },
            )
          ],
        ),
        body: _showLoading?
        Center(
          child: SpinKitThreeBounce(
            color: Colors.lightGreen,
            size: 50.0,
            controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
          ),
        ) : ListView(
          children: <Widget>[
            Container(
              child: _swiperBuilder(),
            ),
            Container(
              child: _categoryBuilder(),
            ),
            Container(
              child: _recommendBuilder(),
            ),
            Container(
              child: _goodsBuilder(),
            ),
          ],
        ));
  }

  Widget _swiperBuilder() {
    return Container(
        width: ScreenUtil().setWidth(750),
        height: 200.0,
        child: Swiper(
          itemBuilder: _swiperItemBuilder,
          itemCount: bannerList.length,
          pagination: new SwiperPagination(
              builder: DotSwiperPaginationBuilder(
            color: Colors.black54,
            activeColor: Colors.white,
          )),
          scrollDirection: Axis.horizontal,
          autoplay: false,
        ));
  }

  Widget _swiperItemBuilder(BuildContext context, int index) {
    return (Image.network(
      bannerList[index]['img_url'],
      fit: BoxFit.fill,
    ));
  }

  Widget _categoryBuilder() {
    return Container(
      child: Wrap(
        alignment: WrapAlignment.start,
        children: Boxs(),
      ),
    );
  }

  List<Widget> Boxs() => List.generate(categoryList.length, (index) {
    return GestureDetector(
      onTap: (){
        Application.router.navigateTo(context, Routes.goodsListPage+'?catid=${categoryList[index]['id']}&sercon=');
      },
      child: Container(
        margin: EdgeInsets.only(top: 10),
        width: ScreenUtil().setWidth(187),
        height: ScreenUtil().setWidth(150),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            FadeInImage.assetNetwork(
              placeholder: 'assets/images/empty.png',
              image: categoryList[index]['img_url'],
              width: ScreenUtil().setWidth(80),
            ),
            Text(
              categoryList[index]['type_name'],
              style: TextStyle(height: 1.5),
            )
          ],
        ),
      ),
    );
  });

  Widget _recommendBuilder(){
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: ScreenUtil().setHeight(80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/recommend.png'),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              recommendList[0]!=null?Container(
                width: ScreenUtil().setWidth(480),
                height: ScreenUtil().setHeight(250),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/empty.png',
                  image: recommendList[0]['img_url'],
                  fit: BoxFit.fill,
                ),
              ):Container(
                width: ScreenUtil().setWidth(480),
                height: ScreenUtil().setHeight(250),
              ),
              recommendList[1]!=null?Container(
                margin: EdgeInsets.only(left: 10),
                width: ScreenUtil().setWidth(250),
                height: ScreenUtil().setHeight(250),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/empty.png',
                  image: recommendList[1]['img_url'],
                  fit: BoxFit.fill,
                ),
              ):Container(
                margin: EdgeInsets.only(left: 10),
                width: ScreenUtil().setWidth(250),
                height: ScreenUtil().setHeight(250),
              ),
            ],
          ),
         Container(
           margin: EdgeInsets.only(top: 10),
           child: Row(
             children: <Widget>[
               recommendList[2]!=null?Container(
                 width: ScreenUtil().setWidth(190),
                 height: ScreenUtil().setHeight(250),
                 child: FadeInImage.assetNetwork(
                   placeholder: 'assets/images/empty.png',
                   image: recommendList[2]['img_url'],
                   fit: BoxFit.fill,
                 ),
               ):Container(
                 width: ScreenUtil().setWidth(190),
                 height: ScreenUtil().setHeight(250),
               ),
               recommendList[3]!=null?Container(
                 margin: EdgeInsets.only(left: 10,right: 10),
                 width: ScreenUtil().setWidth(320),
                 height: ScreenUtil().setHeight(250),
                 child: FadeInImage.assetNetwork(
                   placeholder: 'assets/images/empty.png',
                   image: recommendList[3]['img_url'],
                   fit: BoxFit.fill,
                 ),
               ):Container(
                 margin: EdgeInsets.only(left: 10,right: 10),
                 width: ScreenUtil().setWidth(320),
                 height: ScreenUtil().setHeight(250),
               ),
               recommendList[4]!=null?Container(
                 width: ScreenUtil().setWidth(190),
                 height: ScreenUtil().setHeight(250),
                 child: FadeInImage.assetNetwork(
                   placeholder: 'assets/images/empty.png',
                   image: recommendList[4]['img_url'],
                   fit: BoxFit.fill,
                 ),
               ):Container(
                 width: ScreenUtil().setWidth(190),
                 height: ScreenUtil().setHeight(250),
               ),
             ],
           ),
         )
        ],
      ),
    );
  }

  Widget _goodsBuilder() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          Container(
            height: ScreenUtil().setHeight(50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/home_like.png',
                  width: ScreenUtil().setWidth(40),
                ),
                Image.asset('assets/images/like_title.png'),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Waterfall(goodsList),
          )
        ],
      ),
    );
  }


}
