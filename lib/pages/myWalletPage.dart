import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWalletPage extends StatefulWidget {
  @override
  _MyWalletPageState createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage> with TickerProviderStateMixin {

  ///用户信息
  Map userInfo;
  ///显示加载动画
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    setState(() {
      _showLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///参数
    var userid = prefs.getString('userId').toString();
    var formData = {'uid': userid};
    request('userInfoPageContent', formData: formData).then((val) {
      var data = json.decode(val.toString());
      if (data['code'] == 200) {
        setState(() {
          userInfo = data['data'];
          _showLoading = false;
        });
      }
    });
  }


  List middle_list = [{'icon':'assets/images/charge.png','name':'充值'},{'icon':'assets/images/tx.png','name':'提现'},{'icon':'','name':''},{'icon':'','name':''}];
  List bottom_list = [{'icon':'assets/images/charge_list.png','name':'充值记录'},{'icon':'assets/images/tx_list.png','name':'提现记录'},{'icon':'','name':''},{'icon':'','name':''}];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: Container(
          child: AppBar(
            title: Text('我的钱包'),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(95,61,235,1),
                Color.fromRGBO(89,140,255,1)
              ],
            ),
          ),
        ),
        preferredSize:  Size(MediaQuery.of(context).size.width, 45),
      ),
      body: _showLoading ?
      Center(
        child: SpinKitThreeBounce(
          color: Colors.lightGreen,
          size: 50.0,
          controller: AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 1200)),
        ),
      ) : Container(
        child: Column(
          children: <Widget>[
            _top_widget(),
            _middle_widget(),
            _bottom_widget(),
          ],
        ),
      ),
    );
  }

  ///最上边
  Widget _top_widget(){
    return Container(
      decoration: new BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color.fromRGBO(95,61,235,1), Color.fromRGBO(89,140,255,1)]),
      ),
      height: ScreenUtil().setHeight(250),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(250),
            margin: EdgeInsets.only(top: 30),
            child: Column(
              children: <Widget>[
                Image.asset('assets/images/score.png',width: ScreenUtil().setWidth(70),),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text('我的积分',style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(28)
                  ),),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text('0',style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(28)
                  ),),
                )
              ],
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(250),
            margin: EdgeInsets.only(top: 30),
            child: Column(
              children: <Widget>[
                Image.asset('assets/images/money.png',width: ScreenUtil().setWidth(70),),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text('余额',style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(28)
                  ),),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text('¥ ${userInfo['amount']}',style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(28)
                  ),),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: (){
              Application.router.navigateTo(context, Routes.myAccountPage);
            },
            child: Container(
              width: ScreenUtil().setWidth(250),
              margin: EdgeInsets.only(top: 30),
              child: Column(
                children: <Widget>[
                  Image.asset('assets/images/account.png',width: ScreenUtil().setWidth(70),),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text('我的账户',style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(28)
                    ),),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  ///中间
  Widget _middle_widget(){
    return Container(
      child: Wrap(
        spacing: 0, //主轴上子控件的间距
        runSpacing: 0, //交叉轴上子控件之间的间距
        children: Boxs(), //要显示的子控件集合
      ),
    );
  }
  List<Widget> Boxs() => List.generate(middle_list.length, (index) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      width: ScreenUtil().setWidth(185),
      height: ScreenUtil().setWidth(185),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                middle_list[index]['icon'] != ''?Image.asset(middle_list[index]['icon'],width: ScreenUtil().setWidth(70),):Text(''),
                Container(
                  margin: EdgeInsets.only(top: 3),
                  child: Text(middle_list[index]['name'],style: TextStyle(
                      color: Color.fromRGBO(98,61,229,1),
                      fontSize: ScreenUtil().setSp(28)
                  ),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });


  ///下边
  Widget _bottom_widget(){
    return Container(
      child: Wrap(
        spacing: 0, //主轴上子控件的间距
        runSpacing: 0, //交叉轴上子控件之间的间距
        children: bottom_boxs(), //要显示的子控件集合
      ),
    );
  }
  List<Widget> bottom_boxs() => List.generate(bottom_list.length, (index) {
    return Container(
      width: ScreenUtil().setWidth(185),
      height: ScreenUtil().setWidth(185),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                bottom_list[index]['icon'] != ''?Image.asset(bottom_list[index]['icon'],width: ScreenUtil().setWidth(70),):Text(''),
                Container(
                  margin: EdgeInsets.only(top: 3),
                  child: Text(bottom_list[index]['name'],style: TextStyle(
                      color: Color.fromRGBO(98,61,229,1),
                      fontSize: ScreenUtil().setSp(28)
                  ),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });
}