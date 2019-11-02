import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AlipayBandPage extends StatefulWidget {
  String alipay_id;
  AlipayBandPage({this.alipay_id});

  @override
  _AlipayBandPageState createState() => _AlipayBandPageState();
}

class _AlipayBandPageState extends State<AlipayBandPage> {

  TextEditingController account_controller = new TextEditingController();
  TextEditingController accountname_controller = new TextEditingController();

  ///绑定账号
  void band_account() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = widget.alipay_id;
    ///参数
    var uid = prefs.getString('userId').toString();
    if(id == null || id.isEmpty || id == '0'){
      //添加
      var formData = {"tid":"1","uid":uid,"account":account_controller.text,"accountname":accountname_controller.text,"tphone":""};
      request('add_account_api', formData: formData).then((val) {
        var data = json.decode(val.toString());
        if (data['code'] == 200) {
          Navigator.of(context).pop();
        }
        toast(data['message']);
      });
    }else{
      //修改
      var formData = {"id": id,"account":account_controller.text,"accountname":accountname_controller.text};
      request('edit_account_api', formData: formData).then((val) {
        var data = json.decode(val.toString());
        if (data['code'] == 200) {
          Navigator.of(context).pop();
        }
        toast(data['message']);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('绑定支付宝'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30,right: 30,top: 30),
            child: TextField(
              controller: account_controller,
              keyboardType: TextInputType.text,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(28)
              ),
              decoration: InputDecoration(
                hintText: '请输入支付宝',
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 30,right: 30,top: 20),
            child: TextField(
              controller: accountname_controller,
              keyboardType: TextInputType.text,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(28)
              ),
              decoration: InputDecoration(
                hintText: '请输入支付宝收款名',
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            width: ScreenUtil().setWidth(500),
            height: ScreenUtil().setHeight(70),
            child: MaterialButton(
              onPressed: (){
                band_account();
              },
              color: Color.fromRGBO(7,193,96,1),
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Text('提交',style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil().setSp(28),
              ),),
            ),
          )
        ],
      ),
    );
  }
}
