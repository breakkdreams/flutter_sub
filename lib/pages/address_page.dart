import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressListPage extends StatefulWidget {
  String need_return;
  AddressListPage({this.need_return});

  _AddressListPageState createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> with TickerProviderStateMixin {

  ///显示加载动画
  bool _showLoading = false;
  List addressList = new List();

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
    var formData = {"uid": userid};
    request('address_list_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      print(data);
      if (data['code'] == 200) {
        setState(() {
          addressList = data['data'];
        });
      }
      setState(() {
        _showLoading = false;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的地址'),
        centerTitle: true,
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
          child: Stack(
            children: <Widget>[
              addressList.length<1?Center(
                child: Image.asset('assets/images/empty_data.png'),
              ): ListView.builder(
                itemCount: addressList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      margin: EdgeInsets.only(top: 15),
                      child: ListTile(
                        onTap: (){
                          if(widget.need_return == '1'){
                            Navigator.of(context).pop(addressList[index]);
                          }
                        },
                        leading: addressList[index]['is_default'] == 1
                            ? Icon(Icons.check, color: Colors.red)
                            : Icon(null),
                        title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  "${addressList[index]['receive_name']} ${addressList[index]['receive_phone']}"),
                              SizedBox(height: 10),
                              Text(addressList[index]['address'])
                            ]),
                        trailing: IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                                Application.router.navigateTo(context, Routes.editAddressPage+"?id=${addressList[index]['id']}").then((msg){
                                  _init();
                                });
                            }),
                      ),
                    );
                },
              ),
              Positioned(
                bottom: 0,
                width: ScreenUtil().setWidth(750),
                height: ScreenUtil().setHeight(88),
                child: Container(
                    padding: EdgeInsets.all(5),
                    width: ScreenUtil().setWidth(750),
                    height: ScreenUtil().setHeight(100),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border(
                            top: BorderSide(
                                width: 1, color: Colors.black26))),
                    child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.add, color: Colors.white),
                          Text('增加收货地址',
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                      onTap: () {
                          Application.router.navigateTo(context, Routes.addAddressPage).then((msg){
                            _init();
                          });
                      },
                    )),
              )
            ],
          )
      )
    );
  }
}
