import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgetNextPasswordPage extends StatefulWidget {
  String mobile;
  String mobile_code;
  ForgetNextPasswordPage({this.mobile,this.mobile_code});

  @override
  _ForgetNextPasswordPageState createState() => _ForgetNextPasswordPageState();
}

class _ForgetNextPasswordPageState extends State<ForgetNextPasswordPage> {

  TextEditingController _new_password_controller = new TextEditingController();
  TextEditingController _re_password_controller = new TextEditingController();

  void _update_password() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var formData = {"mobile": widget.mobile,"mobile_code":widget.mobile_code,"new_password":_new_password_controller.text,"re_password":_re_password_controller.text,"type":2};
    request('forget_password_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      if(data['code'] == 200){
        Navigator.pop(context);
      }
      toast(data['message']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置登录密码'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(left: ScreenUtil().setWidth(100),right: ScreenUtil().setWidth(100)),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20),
              child: TextField(
                controller: _new_password_controller,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(28)
                ),
                decoration: InputDecoration(
                    hintText: '请输入新密码',
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: TextField(
                controller: _re_password_controller,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(28)
                ),
                decoration: InputDecoration(
                    hintText: '确认新密码',
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text('必须是6-20个英文字母、数字或符号(除空格)，且字母、数字和标点符号至少包含两种',style: TextStyle(
                color: Color.fromRGBO(102,101,101,1),
              ),),
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
                child: Text('保存新密码',style: TextStyle(
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
