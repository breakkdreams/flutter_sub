import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sub/provide/login_provide.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // 响应空白处的焦点的Node
  FocusNode blankNode = FocusNode();
  ///登录手机号
  TextEditingController _mobile_controller = new TextEditingController();
  ///密码
  TextEditingController _password_controller = new TextEditingController();
  ///昵称
  TextEditingController _name_controller = new TextEditingController();
  ///验证码
  TextEditingController mController = new TextEditingController();
  ///二次密码
  TextEditingController _check_password_controller = new TextEditingController();


  ///密码可见
  bool hide_password = true;
  ///登录false 注册true
  bool show_widget = false;

  bool  isButtonEnable=true;//按钮状态  是否可点击
  String buttonText='发送验证码';//初始文本
  int count=60;//初始倒计时时间
  Timer timer;//倒计时的计时器
  //协议复选框
  bool valueb = false;

  ///注册协议
  String agreementContent = '';

  void _initTimer(){
    timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      count--;
      setState(() {
        if(count==0){
          timer.cancel();             //倒计时结束取消定时器
          isButtonEnable=true;        //按钮可点击
          count=60;                   //重置时间
          buttonText='发送验证码';     //重置按钮文本
        }else{
          buttonText='重新发送($count)';  //更新文本内容
        }
      });
    });
  }

  void _init () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //判断jsapi_ticket有没有值
    var is_jsapi_ticket = prefs.getString('jsapi_ticket');
    if(is_jsapi_ticket !=null && is_jsapi_ticket.isNotEmpty){
      //有值--判断过期时间
      String time_out = prefs.getString('ticket_time_out');
      if(time_out !=null && time_out.isNotEmpty){
        //获取当前时间戳
        var now = new DateTime.now();
        var time_stamp = now.millisecondsSinceEpoch/1000;
        if(int.parse(time_out)<time_stamp){
          print('22222222222222');
          _getaccessToken();
        }
      }else{
        print('333333333333333333');
        _getaccessToken();
      }
    }else{
      print('444444444444444444');
      _getaccessToken();
    }
    ///加密开关(1是开 0是关)
    prefs.setString('secret_open', '1');

    var userid = prefs.getString('userId');
    if(userid !=null && userid.isNotEmpty){
      Application.router.navigateTo(context,Routes.homePage,clearStack: true,);
    }
  }

  void _getaccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///获取accessToken
    http_get('accessToken_api', formData: {'appid':'123456','appsecret':'000000'}).then((val) async {
      var data = json.decode(val.toString());
      if (data['code'] == 200) {
        String access_token = data['data']['access_token'];
        ///获取jsapi_ticket
        http_get('jsapi_ticket_api', formData: {'jti':access_token}).then((val2) async {
          var data2 = json.decode(val2.toString());
          if (data2['code'] == 200) {
            print('11111111111111111111');
            prefs.setString('jsapi_ticket', data2['data']['jsapi_ticket']);
            prefs.setString('ticket_time_out', data2['data']['expires_in'].toString());
          }
        });
      }
    });
  }

  @override
  void initState() {
    _get_agreement();
    _init();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();      //销毁计时器
    timer=null;
    super.dispose();
  }

  //协议显示
  void showCupertinoAlertDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
                height: ScreenUtil().setHeight(600),
                width: ScreenUtil().setWidth(500),
                child:ListView(
                  children: <Widget>[
                    HtmlView(
                        scrollable: false,
                        data:agreementContent),
                  ],
                )
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("不同意"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    valueb = false;
                  });
                },
              ),
              FlatButton(
                child: Text("同意"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    valueb = true;
                  });
                },
              ),
            ],
          );
        });
  }

  ////////////////////////////////////////  接口  /////////////////////////////////////////
  ///发送验证码
  void _send_message(){
    if((_mobile_controller.text).isEmpty && isButtonEnable){
      toast('请输入手机号');
      return;
    }
    if(isButtonEnable){//当按钮可点击时
      setState(() {
        isButtonEnable=false;//按钮状态标记
      });
      _initTimer();
      var formData = {'mobile': _mobile_controller.text};
      request('sendMsg', formData: formData).then((val) async {
        var data = json.decode(val.toString());
        if (data['code'] == 200) {
          toast('短信发送成功!');
        }
      });
      return;
    }
  }
  ///获取注册协议
  void _get_agreement(){
    request('agreementPageContent', formData: {}).then((val) async {
      var data = json.decode(val.toString());
      if (data['code'] == 200) {
        agreementContent = data['data'];
      }
    });
  }
  ///注册
  void _register_sure(){
    var formData = {
      'mobile': _mobile_controller.text,
      'mobile_code':mController.text,
      'nickname':_name_controller.text,
      'password':_password_controller.text,
      're_password':_check_password_controller.text,
      'agreement':valueb
    };
    request('registerPageContent', formData: formData).then((val) async {
      var data = json.decode(val.toString());
      toast(data['message']);
      if (data['code'] == 200) {
        setState(() {
          show_widget = false;
          valueb = false;
        });
      }
    });
  }
  ///登录
  void _login_sure() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var formData = {
      'account': _mobile_controller.text,
      'password':_password_controller.text,
    };

    await request('loginPageContent', formData: formData).then((mm){
      print(mm);
    });
    
//    request('loginPageContent', formData: formData).then((msg) {
//
//      print('============');
//      print(msg);
//      print('============');
////      toast(data['message']);
////      if (data['code'] == 200) {
////        prefs.setString('userId', data['data']['uid']);
////        Provide.value<LoginProvide>(context).setUserId(data['data']['uid']);
////        Application.router.navigateTo(context,Routes.homePage,clearStack: true,);
////      }
//    });
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        child:  ListView(
          children: <Widget>[
            _login(),
            _register()
          ],
        ),
        onTap: (){
          // 点击空白页面关闭键盘
          FocusScope.of(context).requestFocus(blankNode);
        },
      )
    );
  }


  ///登录组
  Widget _login(){
    return Offstage(
      offstage: show_widget,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(150)),
            child: Center(
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
            child: TextField(
              controller: _mobile_controller,
              maxLength: 11,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: '手机号',
                  hintText: '请输入手机号'
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
            child: TextField(
              controller: _password_controller,
              obscureText: hide_password,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                suffixIcon: new IconButton(
                  icon: new Icon(hide_password?FontAwesomeIcons.eyeSlash:FontAwesomeIcons.eye,size: 20,),
                  onPressed: () {
                    if(hide_password){
                      setState(() {
                        hide_password = false;
                      });
                    }else{
                      setState(() {
                        hide_password = true;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(750),
            height: ScreenUtil().setHeight(80),
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
            child: MaterialButton(
              color: Color.fromRGBO(16,167,142,1),
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              onPressed: (){
                _login_sure();
              },
              child: Text('登 录',style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(34)
              ),),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
            child: Center(
              child: Text('忘记密码?',style: TextStyle(
                color: Color.fromRGBO(16,167,142,1),
              ),),
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('没有账号? ',),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        show_widget = true;
                        valueb = false;
                      });
                    },
                    child: Text('立即注册',style: TextStyle(
                      color: Color.fromRGBO(16,167,142,1),
                    ),),
                  )
                ],
              )
          ),
        ],
      ),
    );
  }


  ///注册组
  Widget _register(){
    return Offstage(
      offstage: !show_widget,
      child:Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(150)),
            child: Center(
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
            child: TextField(
              controller: _name_controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  labelText: '用户昵称',
                  hintText: '请输入用户昵称'
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
            child: TextField(
              controller: _mobile_controller,
              maxLength: 11,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: '手机号',
                  hintText: '请输入手机号'
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.ideographic,
              children: <Widget>[
                Expanded(
                  child: Padding(padding: EdgeInsets.only(left: 0,right: 0,top: 0),
                    child: TextFormField(
                      maxLines: 1,
                      onSaved: (value) { },
                      controller: mController,
                      textAlign: TextAlign.left,
                      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(6)],
                      decoration: InputDecoration(
                        hintText: ('填写验证码'),
                        hintStyle: TextStyle(
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),),
                ),
                Container(
                  width: 100,
                  child: FlatButton(
                    disabledColor: Colors.grey.withOpacity(0.1),     //按钮禁用时的颜色
                    disabledTextColor: Colors.white,                   //按钮禁用时的文本颜色
                    textColor:isButtonEnable?Colors.white:Colors.black.withOpacity(0.2),                           //文本颜色
                    color: isButtonEnable?Color.fromRGBO(16,167,142,1):Colors.grey.withOpacity(0.1),                          //按钮的颜色
                    splashColor: isButtonEnable?Colors.white.withOpacity(0.1):Colors.transparent,
                    shape: StadiumBorder(side: BorderSide.none),
                    onPressed: (){ setState(() {
                      _send_message();
                    });},
                    child: Text('$buttonText',style: TextStyle(fontSize: 13,),),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
            child: TextField(
              controller: _password_controller,
              obscureText: hide_password,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
            child: TextField(
              controller: _check_password_controller,
              obscureText: hide_password,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: '再次输入密码',
                hintText: '请再次输入密码',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
            child: Container(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: this.valueb,
                    onChanged: (bool value) {
                      setState(() {
                        this.valueb = value;
                      });
                    },
                  ),
                  Text('我已阅读并同意',style: TextStyle(fontSize: ScreenUtil().setSp(24)),),
                  InkWell(
                    onTap: (){
                      showCupertinoAlertDialog();
                    },
                    child: Text('《腾远商城协议》',style: TextStyle(color:Color.fromRGBO(16,167,142,1),fontSize: ScreenUtil().setSp(24)),),
                  ),
                ],
              ),
          )),
          Container(
            width: ScreenUtil().setWidth(750),
            height: ScreenUtil().setHeight(80),
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(80)),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
            child: MaterialButton(
              color: Color.fromRGBO(16,167,142,1),
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              onPressed: (){
                _register_sure();
              },
              child: Text('注 册',style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(34)
              ),),
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('已有账号 ',),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        show_widget = false;
                        valueb = false;
                      });
                    },
                    child: Text('立即登录',style: TextStyle(
                      color: Color.fromRGBO(16,167,142,1),
                    ),),
                  )
                ],
              )
          ),
        ],
      ),
    );
  }
}
