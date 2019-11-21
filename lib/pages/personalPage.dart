import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/data_service.dart';
import 'dart:convert';

class PersonalPage extends StatefulWidget {
  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage>
    with TickerProviderStateMixin {
  ///显示加载动画
  bool _showLoading = false;

  ///用户信息
  Map userInfo;
  ///商品收藏和浏览足迹
  Map grInfo;
  ///我的工具
  List toolsList;

  @override
  void initState() {
    _init();


    super.initState();
  }

  void _init() async {
    setState(() {
      _showLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///参数
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid};
    String secret_open = prefs.getString('secret_open');//1开 0关
    if(secret_open == '1') { //要加密
      lock(formData).then((params){
        formData = {'data':params};
        request('userInfoPageContent', formData: formData).then((val) {
          var data = json.decode(val.toString());

          delock(data['data']).then((unlock_data){
            data['data'] = json.decode(unlock_data.toString());
            setState(() {
              userInfo = data['data'];
            });
            _init2();
          });

        });
      });
    }
  }

  void _init2() async {
    setState(() {
      _showLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///参数
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid};
    String secret_open = prefs.getString('secret_open');//1开 0关
    if(secret_open == '1') { //要加密
      lock(formData).then((params){
        formData = {'data':params};
        request('grPageContent', formData: formData).then((val) {
          var data = json.decode(val.toString());
          delock(data['data']).then((unlock_data){
            data['data'] = json.decode(unlock_data.toString());
            setState(() {
              grInfo = data['data'];
            });
            _init3();
          });

        });
      });
    }
  }

  void _init3() async {
    setState(() {
      _showLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///参数
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid};
    String secret_open = prefs.getString('secret_open');//1开 0关
    if(secret_open == '1') { //要加密
      lock(formData).then((params){
        formData = {'data':params};
        request('myToolsPageContent', formData: formData).then((val) {
          var data = json.decode(val.toString());
          setState(() {
            toolsList = data['data'];
            _showLoading = false;
          });

        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child: Image.asset(
              'assets/images/head_bg.jpg',
              height: ScreenUtil().setHeight(500),
              fit: BoxFit.cover,
            ),
          ),
          Container(
              child: _showLoading ?
              Center(
                child: SpinKitThreeBounce(
                  color: Colors.lightGreen,
                  size: 50.0,
                  controller: AnimationController(
                      vsync: this,
                      duration: const Duration(milliseconds: 1200)),
                ),
              )
            : ListView(
                padding: EdgeInsets.all(0.0),
                children: <Widget>[
                  _head_area(),
                  _order_area(),
                  _my_tool()
                ],
              )),
        ],
      ),
    );
  }

  ///用户头像区
  Widget _head_area() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: ScreenUtil().setWidth(750),
        padding: EdgeInsets.only(top: 20, bottom: 40, left: 20),
        margin: EdgeInsets.only(top: ScreenUtil().setHeight(60)),
        child: Column(
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(750),
              margin: EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(FontAwesomeIcons.cog,color: Color.fromRGBO(128,128,128,1),),
                    onPressed: (){
                      Application.router.navigateTo(context,Routes.editPersonalPage);
                    },
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    child: ClipOval(
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/empty.png',
                        image: userInfo['avatar'],
                        width: ScreenUtil().setWidth(120),
                        height: ScreenUtil().setWidth(120),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Row(
                          children: <Widget>[
                            Text(
                              userInfo['nickname'],
                              style: TextStyle(
                                  color: Colors.white, fontSize: ScreenUtil().setSp(32)),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color.fromRGBO(237,210,114,1),
                              ),
                              child: Text(
                                '购物卡',
                                style: TextStyle(
                                    color: Colors.white, fontSize: ScreenUtil().setSp(30)),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                          ),
                        ),
                        padding: EdgeInsets.only(left: 18,right: 18,top: 2,bottom: 2),
                        child: Row(
                          children: <Widget>[
                            Text(
                              '余额 ¥ ${userInfo['amount']}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: ScreenUtil().setSp(28)),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Image.asset('assets/images/sale.png',width: ScreenUtil().setWidth(130),),
                  ),
                ],
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(750),
              margin: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text(grInfo['collection'].toString(),style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(38)
                        ),),
                        Text('商品收藏',style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(28)
                        ),)
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text(grInfo['footprint'].toString(),style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(38)
                        ),),
                        Text('浏览足迹',style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(28)
                        ),)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  ///订单区
  Widget _order_area(){
    return  Container(
      margin: EdgeInsets.only(
          left: ScreenUtil().setWidth(38), right: ScreenUtil().setWidth(38)),
      width: ScreenUtil().setWidth(ScreenUtil().setHeight(674)),
      height: ScreenUtil().setHeight(ScreenUtil().setHeight(260)),
      padding: EdgeInsets.only(top: 30),
      decoration: new BoxDecoration(
        //设置子控件背后的装饰
        color: Colors.white,
        borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
        // 生成俩层阴影，一层绿，一层黄， 阴影位置由offset决定,阴影模糊层度由blurRadius大小决定（大就更透明更扩散），阴影模糊大小由spreadRadius决定
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(220, 220, 220, 0.7),
              offset: Offset(5.0, 5.0),
              blurRadius: 10.0,
              spreadRadius: 0.1)
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(130),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/after_sale.png",
                      width: ScreenUtil().setWidth(50),
                    ),
                    Text(
                      '售后/退换',
                      style: TextStyle(height: 2),
                    ),
                  ],
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(130),
                child: GestureDetector(
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        "assets/images/my_order.png",
                        width: ScreenUtil().setWidth(50),
                      ),
                      Text(
                        '我的订单',
                        style: TextStyle(height: 2),
                      ),
                    ],
                  ),
                  onTap: () {
                    Application.router.navigateTo(context, Routes.orderListPage);
                  },
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(130),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/daifukuan.png",
                      width: ScreenUtil().setWidth(50),
                    ),
                    Text(
                      '待付款',
                      style: TextStyle(height: 2),
                    ),
                  ],
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(130),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/daifahuo.png",
                      width: ScreenUtil().setWidth(50),
                    ),
                    Text(
                      '待发货',
                      style: TextStyle(height: 2),
                    ),
                  ],
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(130),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/daishouhuo.png",
                      width: ScreenUtil().setWidth(50),
                    ),
                    Text(
                      '待收货',
                      style: TextStyle(height: 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///我的工具
  Widget _my_tool(){
    return Container(
      margin: EdgeInsets.only(left: ScreenUtil().setWidth(38), right: ScreenUtil().setWidth(38),top: 30,bottom: 50),
      width: ScreenUtil().setWidth(ScreenUtil().setHeight(674)),
      padding: EdgeInsets.only(top: 20),
      decoration: new BoxDecoration(
        //设置子控件背后的装饰
        color: Colors.white,
        borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
        // 生成俩层阴影，一层绿，一层黄， 阴影位置由offset决定,阴影模糊层度由blurRadius大小决定（大就更透明更扩散），阴影模糊大小由spreadRadius决定
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(220, 220, 220, 0.7),
              offset: Offset(5.0, 5.0),
              blurRadius: 10.0,
              spreadRadius: 0.1)
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(750),
            margin: EdgeInsets.only(left: 20),
            child: Text('我的工具',style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil().setSp(32)
            ),),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Wrap(
              spacing: 2, //主轴上子控件的间距
              runSpacing: 5, //交叉轴上子控件之间的间距
              children: Boxs(), //要显示的子控件集合
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> Boxs() => List.generate(toolsList.length, (index) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      width: ScreenUtil().setWidth(160),
      height: ScreenUtil().setWidth(160),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: (){
          if(toolsList[index]['catname'] == '安全中心'){
            Application.router.navigateTo(context,Routes.safetyCenterPage);
          }else if(toolsList[index]['catname'] == '我的钱包'){
            Application.router.navigateTo(context,Routes.myWalletPage);
          }else if(toolsList[index]['catname'] == '地址管理'){
            Application.router.navigateTo(context,Routes.addressListPage+"?need_return=0");
          }else if(toolsList[index]['catname'] == '消息中心'){
            Application.router.navigateTo(context,Routes.messageListPage);
          }
        },
        child: Column(
          children: <Widget>[
            FadeInImage.assetNetwork(
              placeholder: 'assets/images/empty.png',
              image: toolsList[index]['icon'],
              width: ScreenUtil().setSp(80),
            ),
            Text(toolsList[index]['catname'],style: TextStyle(
                height: 1.8
            ),)
          ],
        ),
      )
    );
  });


}