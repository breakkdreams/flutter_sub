import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPersonalPage extends StatefulWidget {
  @override
  _EditPersonalPageState createState() => _EditPersonalPageState();
}

class _EditPersonalPageState extends State<EditPersonalPage> with TickerProviderStateMixin {

  ///显示加载动画
  bool _showLoading = false;
  ///用户信息
  Map userInfo;

  ///昵称
  TextEditingController _nickNameController = TextEditingController();

  File _image;

  /*
  * 通过图片路径将图片转换成Base64字符串
  */
  static Future image2Base64(String path) async {
    File file = new File(path);
    List<int> imageBytes = await file.readAsBytes();
    return base64Encode(imageBytes);
  }


  Future getImage(type) async {
    var image;
    //相册
    if(type == 1){
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }else{
      image = await ImagePicker.pickImage(source: ImageSource.camera);
    }
    _upLoadImage(image);
  }

  ///上传图片
  _upLoadImage(File image) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    String path = image.path;
    image2Base64(path).then((data){
      var formData = { "file": 'data:image/jpeg;base64,'+data, "uid":userid,"types":1};
      request('uploadHeadImgContent', formData: formData).then((val) async {
        var data = json.decode(val.toString());
        _init();
        toast(data['message']);
      });
    });
  }
  
  ///退出登录
  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    Application.router.navigateTo(context,Routes.loginPage,clearStack: true,);
  }


  //修改用户信息
  _updateUserInfo(nickname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    var formData = {'uid': userid,'val':nickname,'field':'nickname'};
    request('updateUserPageContent', formData: formData).then((val) async {
      var data = json.decode(val.toString());
      if (data['code'] == 200)  {
        _nickNameController.clear();
      }
      _init();
      toast(data['message']);
    });
  }

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
    request('userInfoPageContent', formData: formData).then((val) async {
      var data = json.decode(val.toString());
      if (data['code'] == 200) {
        setState(() {
          userInfo = data['data'];
          _showLoading = false;
          _nickNameController.text = userInfo['nickname'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('编辑个人资料'),
        centerTitle: true,
      ),
      body: _showLoading?
      Center(
        child: SpinKitThreeBounce(
          color: Colors.lightGreen,
          size: 50.0,
          controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
        ),
      ) : Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text('基本信息',style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          color: Color.fromRGBO(153,153,153,1),
                        ),),
                        padding: EdgeInsets.only(left: 20,top: 20),
                        width: ScreenUtil().setWidth(750),
                      ),
                      GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  left: ScreenUtil().setSp(30),
                                  bottom: ScreenUtil().setHeight(30),
                                  top: ScreenUtil().setHeight(30)),
                              child: Text(
                                '头像',
                                style:
                                TextStyle(fontSize: ScreenUtil().setSp(28)),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  right: ScreenUtil().setSp(30),
                                  bottom: ScreenUtil().setHeight(30),
                                  top: ScreenUtil().setHeight(30)),
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage: new NetworkImage(userInfo['avatar']),
                                  ),
                                  Icon(Icons.keyboard_arrow_right),
                                ],
                              ),
                            )
                          ],
                        ),
                        onTap: (){
                          showModalBottomSheet(
                              context: context,
                              builder: (builder){
                                return new Container(
                                  height: 130.0,
                                  color: Colors.transparent, //could change this to Color(0xFF737373),
                                  //so you don't have to change MaterialApp canvasColor
                                  child: new Container(
                                      decoration: new BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: new BorderRadius.only(
                                              topLeft: const Radius.circular(10.0),
                                              topRight: const Radius.circular(10.0))),
                                      child: new Center(
                                        child: Column(
                                          children: <Widget>[
                                            ListTile(
                                              title: Text('相机',textAlign: TextAlign.center,),
                                              onTap: (){
                                                getImage(2);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            ListTile(
                                              title: Text('相册',textAlign: TextAlign.center,),
                                              onTap: (){
                                                getImage(1);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      )),
                                );
                              }
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                                left: ScreenUtil().setSp(30),
                                bottom: ScreenUtil().setHeight(30),
                                top: ScreenUtil().setHeight(30)),
                            child: Text(
                              '用户编码',
                              style:
                              TextStyle(fontSize: ScreenUtil().setSp(28)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                right: ScreenUtil().setSp(30),
                                bottom: ScreenUtil().setHeight(30),
                                top: ScreenUtil().setHeight(30)),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  userInfo['username'],
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(28)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  left: ScreenUtil().setSp(30),
                                  bottom: ScreenUtil().setHeight(30),
                                  top: ScreenUtil().setHeight(30)),
                              child: Text(
                                '昵称',
                                style:
                                TextStyle(fontSize: ScreenUtil().setSp(28)),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  right: ScreenUtil().setSp(30),
                                  bottom: ScreenUtil().setHeight(30),
                                  top: ScreenUtil().setHeight(30)),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    userInfo['nickname'],
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(28)),
                                  ),
                                  Icon(Icons.keyboard_arrow_right),
                                ],
                              ),
                            )
                          ],
                        ),
                        onTap: (){
                          showDialog<Null>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return new AlertDialog(
                                  title: new Text('修改昵称'),
                                  //可滑动
                                  content: new SingleChildScrollView(
                                    child: new ListBody(
                                      children: <Widget>[
                                        TextField(
                                          controller: _nickNameController,
                                        )
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    new FlatButton(
                                      child: new Text('取消'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    new FlatButton(
                                      child: new Text('确定'),
                                      onPressed: () {
                                        _updateUserInfo(_nickNameController.text);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                      ),
                      _account_phone(),
                    ],
                  ))
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              color: Colors.red,
              width: ScreenUtil().setWidth(750),
              height: ScreenUtil().setHeight(80),
              child: MaterialButton(
                onPressed: (){
                  _logout();
                },
                child: Text('退出登录',style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(28),
                ),),
              ),
            ),
          )
        ],
      )
    );
  }


  Widget _account_phone(){
    return Column(
      children: <Widget>[
        Container(
          child: Text('账号绑定与关联',style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: Color.fromRGBO(153,153,153,1),
          ),),
          padding: EdgeInsets.only(left: 20,top: 20),
          width: ScreenUtil().setWidth(750),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                    left: ScreenUtil().setSp(30),
                    bottom: ScreenUtil().setHeight(30),
                    top: ScreenUtil().setHeight(30)),
                child: Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.mobileAlt),
                    Text(
                      '手机号',
                      style:
                      TextStyle(fontSize: ScreenUtil().setSp(28)),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    right: ScreenUtil().setSp(30),
                    bottom: ScreenUtil().setHeight(30),
                    top: ScreenUtil().setHeight(30)),
                child: Row(
                  children: <Widget>[
                    Text(
                      userInfo['mobile'],
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(28)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }


}
