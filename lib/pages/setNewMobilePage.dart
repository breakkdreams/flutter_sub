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

class SetNewMobilePage extends StatefulWidget {
  String old_mobile;
  String old_mobile_code;
  SetNewMobilePage({this.old_mobile,this.old_mobile_code});

  @override
  _SetNewMobilePageState createState() => _SetNewMobilePageState();
}

class _SetNewMobilePageState extends State<SetNewMobilePage> {
  TextEditingController mController = new TextEditingController();
  TextEditingController _new_mobile_controller = new TextEditingController();
  bool  isButtonEnable=true;
  String buttonText='发送验证码';
  int count=60;
  Timer timer;

  void _initTimer(){
    timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      count--;
      setState(() {
        if(count==0){
          timer.cancel();
          isButtonEnable=true;
          count=60;
          buttonText='发送验证码';
        }else{
          buttonText='重新发送($count)';
        }
      });
    });
  }

  ///发送验证码
  void _send_message() async {
    if((_new_mobile_controller.text).isEmpty && isButtonEnable){
      toast('请输入手机号');
      return;
    }
    if(isButtonEnable){
      setState(() {
        isButtonEnable=false;
      });
      _initTimer();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var formData = {'mobile': _new_mobile_controller.text};
      request('sendMsg', formData: formData).then((val) async {
        var data = json.decode(val.toString());
        if (data['code'] == 200) {
          toast(data['message']);
        }
      });
      return;
    }
  }

  void _update_password() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid,"mobile": widget.old_mobile,"mobile_code":widget.old_mobile_code,"new_mobile": _new_mobile_controller.text,"new_mobile_code":mController.text,"type":2};
    request('forget_mobile_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      if(data['code'] == 200){
        Navigator.pop(context);
      }
      toast(data['message']);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer=null;
    super.dispose();
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
              child: TextField(
                controller: _new_mobile_controller,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(28)
                ),
                decoration: InputDecoration(
                  hintText: '请输入新的手机号码',
                  border: InputBorder.none,
                ),
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
                      disabledColor: Colors.grey.withOpacity(0.1),
                      disabledTextColor: Colors.white,
                      textColor:isButtonEnable?Colors.white:Colors.black.withOpacity(0.2),
                      color: isButtonEnable?Colors.white.withOpacity(0):Colors.grey.withOpacity(0.1),
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
              margin: EdgeInsets.only(top: 10),
              child: Row(
                children: <Widget>[
                  Text('绑定的手机号码已不在使用,请联系客服',style: TextStyle(
                    color: Color.fromRGBO(102,101,101,1),
                  ),)
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
                child: Text('确定',style: TextStyle(
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
