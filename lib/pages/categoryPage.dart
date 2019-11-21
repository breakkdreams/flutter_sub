import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/data_service.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPagetate createState() => _CategoryPagetate();
}

class _CategoryPagetate extends State<CategoryPage> with TickerProviderStateMixin  {

  List list = [];
  var listIndex = 0; //索引
  ///显示加载动画
  bool _showLoading = false;

  var childList;
  var imageStr;

  void _getCategory() async {
    setState(() {
      _showLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///参数
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid};

    String secret_open = prefs.getString('secret_open');//1开 0关
    if(secret_open == '1') { //要加密
      lock(formData).then((params){
        formData = {'data':params};
        request('category_list_api', formData: formData).then((val) {
          var data = json.decode(val.toString());
          delock(data['data']).then((unlock_data){
            data['data'] = json.decode(unlock_data.toString());
            setState(() {
              list = data['data'];
              childList = list[listIndex]['children'];
              imageStr = list[listIndex]['catimg'];
              _showLoading = false;
            });
          });

        });
      });
    }
  }

  @override
  void initState() {
    _getCategory();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: new Text('分类'),
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
        child: Row(
          children: <Widget>[
            Container(
                width: ScreenUtil().setWidth(180),
                decoration: BoxDecoration(
                    border: Border(right: BorderSide(width: 1, color: Colors.black12))),
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _leftMenu(index);
                  },
                )),
            Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          top: ScreenUtil().setWidth(10),
                          left: ScreenUtil().setWidth(10),
                          right: ScreenUtil().setWidth(10)),
                      child: Image.network(
                        imageStr,
                        width: ScreenUtil().setWidth(550),
                        height: ScreenUtil().setHeight(230),
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      height: size.height - 350,
                      width: ScreenUtil().setWidth(570),
                      child: buildGrid(childList),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  //菜单的文字
  Widget _leftMenu(int index) {
    bool isClick = false;
    isClick = (index == listIndex) ? true : false;

    return InkWell(
      onTap: () {
        setState(() {
          listIndex = index;
          childList = list[index]['children'];
          imageStr = list[index]['catimg'];
        });
      },
      child: Container(
        height: ScreenUtil().setHeight(80),
        padding: EdgeInsets.only(left: 10, top: 20),
        decoration: BoxDecoration(
            color: isClick ? Colors.blue : Colors.white,
            border:
            Border(bottom: BorderSide(width: 1, color: Colors.black12))),
        child: Text(list[index]['catname'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: isClick ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _rightMenu(Map item) {
    return InkWell(
      child: Container(
          padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  Application.router.navigateTo(context, Routes.goodsListPage+'?catid=${item['catid']}&sercon=');
                },
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/empty.png',
                  image: item['catimg'],
                  width: ScreenUtil().setWidth(100),
                  height: ScreenUtil().setWidth(100),
                  fit: BoxFit.fill,
                ),
              ),
              Text(
                item['catname'],
                style: TextStyle(fontSize: ScreenUtil().setSp(26)),
              ),
            ],
          )),
    );
  }

  Widget buildGrid(List formList) {
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    if(formList == null){
      return Center(
        child: Text('暂无数据'),
      );
    }
    for (int i = 0; i < formList.length; i++) {
      var item = formList[i];
      var itemCounts = 0;
      if (item['children'] != null) {
        itemCounts = item['children'].length;
      }
      tiles.add(new Column(children: <Widget>[
        Container(
          width: ScreenUtil().setWidth(450),
          child: Text(
            item['catname'],
            textAlign: TextAlign.left,
            style: TextStyle(
              height: 1.5,
              fontSize: 18,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //横轴元素个数
              crossAxisCount: 3,
              //横轴间距
              crossAxisSpacing: 10.0,
              //子组件宽高长度比例
              childAspectRatio: 0.8),
          itemBuilder: (context, index) {
            if (item['children'] != null) {
              return _rightMenu(item['children'][index]);
            } else {
              return null;
            }
          },
          itemCount: itemCounts,
        ),
      ]));
    }
    content = new Column(
        children: tiles //重点在这里，因为用编辑器写Column生成的children后面会跟一个<Widget>[]，
      //此时如果我们直接把生成的tiles放在<Widget>[]中是会报一个类型不匹配的错误，把<Widget>[]删了就可以了
    );

    return content;
  }

}