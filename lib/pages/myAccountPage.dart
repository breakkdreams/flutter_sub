import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountPage extends StatefulWidget {
  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage>
    with TickerProviderStateMixin {
  bool _showLoading = false;
  Map infoData;

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
    var userid = prefs.getString('userId').toString();
    var formData = {'uid': userid};
    request('my_account_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      print(data);
      if (data['code'] == 200) {
        setState(() {
          infoData = data['data'];
          _showLoading = false;
        });
      }
    });
  }


  void _set_default(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String secret_open = prefs.getString('secret_open');
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid,"id":id};
    if (secret_open == '1') {
      var lock_data = lock(formData);
      lock_data.then((params) {
        request('set_default_bank_api', formData: {'data': params}).then((val) {
          var data = json.decode(val.toString());
          var unlock = delock(data['data']);
          unlock.then((unlock_data) {
            var result = json.decode(unlock_data);
            if (result['code'] == 200) {

            }
            toast(data['message']);
          });
        });
      });
    } else {
      request('set_default_bank_api', formData: formData).then((val) {
        var data = json.decode(val.toString());
        if (data['code'] == 200) {
          _init();
        }
        toast(data['message']);
      });
    }
  }

  void _deleted_account(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String secret_open = prefs.getString('secret_open');
    var userid = prefs.getString('userId').toString();
    var formData = {"id":id};
    if (secret_open == '1') {
      var lock_data = lock(formData);
      lock_data.then((params) {
        request('deleted_account_api', formData: {'data': params}).then((val) {
          var data = json.decode(val.toString());
          var unlock = delock(data['data']);
          unlock.then((unlock_data) {
            var result = json.decode(unlock_data);
            if (result['code'] == 200) {

            }
            toast(data['message']);
          });
        });
      });
    } else {
      request('deleted_account_api', formData: formData).then((val) {
        var data = json.decode(val.toString());
        if (data['code'] == 200) {
          _init();
        }
        toast(data['message']);
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的账户'),
        centerTitle: true,
      ),
      body: _showLoading
          ? Center(
              child: SpinKitThreeBounce(
                color: Colors.lightGreen,
                size: 50.0,
                controller: AnimationController(
                    vsync: this, duration: const Duration(milliseconds: 1200)),
              ),
            )
          : Column(
              children: <Widget>[
                ListTile(
                  onTap: () {
                    Application.router
                        .navigateTo(
                            context,
                            Routes.bandWeChatPage +
                                '?id=' +
                                infoData['weixin_id'].toString())
                        .then((msg) {
                      _init();
                    });
                  },
                  leading: Icon(
                    FontAwesomeIcons.weixin,
                    color: Color.fromRGBO(60, 176, 53, 1),
                    size: 30,
                  ),
                  title: Text(
                    '微信',
                    style: TextStyle(fontSize: ScreenUtil().setSp(32)),
                  ),
                  subtitle: infoData['weixin'] == '2'
                      ? Text('已绑定 ${infoData['weixin_account']}')
                      : Text('未绑定'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () {
                    Application.router
                        .navigateTo(
                            context,
                            Routes.aliPayBandPage +
                                '?id=' +
                                infoData['zhifubao_id'].toString())
                        .then((msg) {
                      _init();
                    });
                  },
                  leading: Icon(
                    FontAwesomeIcons.alipay,
                    color: Color.fromRGBO(0, 167, 240, 1),
                    size: 30,
                  ),
                  title: Text(
                    '支付宝',
                    style: TextStyle(fontSize: ScreenUtil().setSp(32)),
                  ),
                  subtitle: infoData['zhifubao'] == '2'
                      ? Text('已绑定 ${infoData['zhifubao_account']}')
                      : Text('未绑定'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  onTap: () {
                    Application.router
                        .navigateTo(context, Routes.bankBandPage)
                        .then((msg) {
                      _init();
                    });
                  },
                  leading: Icon(
                    Icons.payment,
                    color: Color.fromRGBO(255, 109, 0, 1),
                    size: 30,
                  ),
                  title: Text(
                    '银行卡',
                    style: TextStyle(fontSize: ScreenUtil().setSp(32)),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                _bank_list(),
              ],
            ),
    );
  }

  Widget _bank_list() {
    List bankList = infoData['content'];
    for(var items in bankList){
      String account  = items['account'];
      String first_number = account.substring(0,6);
      String last_number = account.substring(account.length-4,account.length);
      String final_number = first_number+'  ****  ****  '+last_number;
      items['account'] = final_number;
    }
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: ListView.builder(
        shrinkWrap: true,
        physics: new NeverScrollableScrollPhysics(),
        itemCount: bankList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: Color.fromRGBO(254, 105, 106, 1),
            elevation: 8.0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14.0))),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: new ListTile(
                      leading: ClipOval(
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/empty.png',
                          image: bankList[index]['logo'],
                          width: ScreenUtil().setWidth(110),
                          height: ScreenUtil().setWidth(120),
                          fit: BoxFit.fill,
                        ),
                      ),
                      title: new Text(bankList[index]['bank'],
                          style: new TextStyle(fontSize: ScreenUtil().setSp(28),color: Colors.white)),
                      subtitle: new Text(bankList[index]['desc'],style: TextStyle(
                          color: Colors.white
                      ),),
                      trailing: GestureDetector(
                        onTap: (){
                          if(bankList[index]['is_first'] !=1){
                            _set_default(bankList[index]['id']);
                          }
                        },
                        child: Text(bankList[index]['is_first'] ==1 ? '默认':'设为默认',
                            style: new TextStyle(fontSize: ScreenUtil().setSp(28),color: Colors.white)),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(bankList[index]['account'],style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(32),
                        height: 2
                    ),),
                  ),
                  Container(
                    child: ListTile(
                      trailing: Icon(Icons.delete,color: Colors.white,),
                      onTap: (){
                        _deleted_account(bankList[index]['id']);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
