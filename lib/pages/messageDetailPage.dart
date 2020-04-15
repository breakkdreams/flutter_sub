import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MessageDetailPage extends StatefulWidget {

  String message_id;
  MessageDetailPage({this.message_id});

  @override
  _MessageDetailPageState createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailPage> with TickerProviderStateMixin {
  bool _showLoading = false;
  Map messageInfo;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    setState(() {
      _showLoading = true;
    });
    print(widget.message_id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid,"id":widget.message_id};
    request('message_detail_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      print(data);
      if (data['code'] == 200) {
        setState(() {
          messageInfo = data['data'];
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
        title: Text('消息详情'),
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
      ) : ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              children: <Widget>[
                Container(
                  child: Text(messageInfo['title'],style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(32)
                  ),),
                ),
                Container(
                  child: ListTile(
                    leading: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/empty.png',
                      image: messageInfo['thumb'],
                      width: ScreenUtil().setSp(120),
                    ),
                    title: Text('发布人:${messageInfo['sendname']}'),
                    subtitle: Text(messageInfo['create_time']),
                  ),
                ),
                Container(
                  child: Text(messageInfo['content'],style: TextStyle(
                    fontSize: ScreenUtil().setSp(28)
                  ),),
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}
