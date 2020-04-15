import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/secret.dart';

class SafetyCenterPage extends StatefulWidget {
  @override
  _SafetyCenterPageState createState() => _SafetyCenterPageState();
}

class _SafetyCenterPageState extends State<SafetyCenterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('安全中心'),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('修改登录密码',style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
              ),),
              subtitle: Text('建议您定期更改密码以保护账户安全'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: (){
                showDialog<Null>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return new CupertinoAlertDialog(
                      title: new Text('你是否记得原登录密码?',textAlign: TextAlign.center,),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('否'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Application.router.navigateTo(context,Routes.forgetPasswordPage);
                          },
                        ),
                        new FlatButton(
                          child: new Text('是'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Application.router.navigateTo(context,Routes.setPasswordPage);
                          },
                        ),
                      ],
                    );
                  },
                ).then((val) {
                  print(val);
                });
              },
            ),
            ListTile(
              title: Text('修改支付密码',style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
              ),),
              subtitle: Text('建议您定期更改支付密码以保护财产安全'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: (){
                showDialog<Null>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return new CupertinoAlertDialog(
                      title: new Text('你是否记得原支付密码?',textAlign: TextAlign.center,),
                      content: new SingleChildScrollView(
                        child: new ListBody(
                          children: <Widget>[
                            new Text('(第一次设置密码请点击"否")',textAlign: TextAlign.center,),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('否'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Application.router.navigateTo(context,Routes.forgetPayPasswordPage);
                          },
                        ),
                        new FlatButton(
                          child: new Text('是'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Application.router.navigateTo(context,Routes.payPasswordPage);
                          },
                        ),
                      ],
                    );
                  },
                ).then((val) {
                  print(val);
                });
              },
            ),
            ListTile(
              title: Text('修改手机号码',style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
              ),),
              subtitle: Text('若手机更换请尽快修改'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: (){
                Application.router.navigateTo(context,Routes.forgetMobilePage);
              },
            ),
          ],
        ),
      ),
    );
  }
}
