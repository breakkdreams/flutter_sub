import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgetPasswordPage extends StatefulWidget {
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  String mobile = '';

  ///验证码
  TextEditingController mController = new TextEditingController();
  bool  isButtonEnable=true;//按钮状态  是否可点击
  String buttonText='发送验证码';//初始文本
  int count=60;//初始倒计时时间
  Timer timer;//倒计时的计时器

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

  ///发送验证码
  void _send_message() async {
    if(mobile.isEmpty && isButtonEnable){
      toast('请输入手机号');
      return;
    }
    if(isButtonEnable){//当按钮可点击时
      setState(() {
        isButtonEnable=false;//按钮状态标记
      });
      _initTimer();
      var formData = {'mobile': mobile};
      request('sendMsg', formData: formData).then((val) async {
        var data = json.decode(val.toString());
        if (data['code'] == 200) {
          toast(data['message']);
        }
      });
      return;
    }
  }

  ///下一步
  void _update_password() async {
    ///参数
    var formData = {"mobile": mobile,"mobile_code":mController.text,"type":1};
    request('forget_password_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      if(data['code'] == 200){
        Application.router.navigateTo(context,Routes.forgetNextPasswordPage+"?mobile="+mobile+"&mobile_code="+mController.text);
      }
      toast(data['message']);
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    timer?.cancel();      //销毁计时器
    timer=null;
    super.dispose();
  }

  void _init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///参数
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid};
    request('userInfoPageContent', formData: formData).then((val) {
      var data = json.decode(val.toString());
      if(data['code'] == 200){
        setState(() {
          mobile = data['data']['mobile'];
        });
        _send_message();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('手机验证'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Center(
                child: Text('我们已经发送了校验码到你的手机:',style: TextStyle(
                  fontSize: ScreenUtil().setSp(32)
                ),),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Center(
                child: Text(mobile,style: TextStyle(
                    fontSize: ScreenUtil().setSp(32)
                ),),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Row(
                children: <Widget>[
                  Text('为确保是你本人操作，请完成以下验证',style: TextStyle(
                    color: Color.fromRGBO(102,101,101,1),
                  ),)
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
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
                      color: isButtonEnable?Colors.white.withOpacity(0):Colors.grey.withOpacity(0.1),                          //按钮的颜色
                      splashColor: isButtonEnable?Colors.white.withOpacity(0.1):Colors.transparent,
                      shape: StadiumBorder(side: BorderSide.none),
                      onPressed: (){ setState(() {
                        _send_message();
                      });},
                      child: Text('$buttonText',style: TextStyle(fontSize: 13,color: Colors.black),),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 30),
              width: ScreenUtil().setWidth(500),
              height: ScreenUtil().setHeight(70),
              child: MaterialButton(
                onPressed: (){
                  _update_password();
                },
                color: Color.fromRGBO(85,172,237,1),
                shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: Text('下一步',style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(28),
                ),),
              ),
            )
          ],
        ),
      )
    );
  }
}
