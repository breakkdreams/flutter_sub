import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageListPage extends StatefulWidget {
  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> with TickerProviderStateMixin {
  bool _showLoading = false;
  List messageList;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    setState(() {
      _showLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid};
    request('message_list_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      if (data['code'] == 200) {
        setState(() {
          messageList = data['data']['data'];
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
        title: Text('消息中心'),
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
      ) : ListView.builder(
        itemCount: messageList.length,
        itemBuilder: (BuildContext context,int index){
          return _item_widget(index);
        },
      ),
    );
  }

  Widget _item_widget(index){
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(20),
      child: ListTile(
        onTap: (){
          print(Routes.messageDetailPage+"?id=${messageList[index]['id']}");
          Application.router.navigateTo(context, Routes.messageDetailPage+"?id=${messageList[index]['id']}");
        },
        title: Text(messageList[index]['title'],style: TextStyle(
          fontSize: ScreenUtil().setSp(30)
        ),),
        subtitle: Container(
          margin: EdgeInsets.only(top:10,bottom: 10),
          width: ScreenUtil().setWidth(750),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(messageList[index]['content'],style: TextStyle(
                      fontSize: ScreenUtil().setSp(30)
                  ),),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child:Text('发送人:${messageList[index]['sendname']}',style: TextStyle(
                        fontSize: ScreenUtil().setSp(28)
                    ),),
                  )
                ],
              )
            ],
          ),
        ),
        trailing: FadeInImage.assetNetwork(
          placeholder: 'assets/images/empty.png',
          image: messageList[index]['thumb'],
          width: ScreenUtil().setSp(120),
        ),
      )
    );
  }
}
