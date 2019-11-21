import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/index_page.dart';

class OrderListPage extends StatefulWidget {
  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class TabTitle {
  const TabTitle({this.name, this.status});

  final String name;
  final int status;
}

class _OrderListPageState extends State<OrderListPage>
    with TickerProviderStateMixin {
  TabController mController;
  List<TabTitle> tabList;
  int tabStatus = 1;
  List orderList;

  ///显示加载动画
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    initTabData();
    tabList = [
      new TabTitle(name: '全部', status: 1),
      new TabTitle(name: '待付款', status: 2),
      new TabTitle(name: '待发货', status: 3),
      new TabTitle(name: '待收货', status: 4),
      new TabTitle(name: '待评价', status: 5),
    ];

    mController = TabController(
      vsync: this,
      length: tabList.length,
    );
    //添加监听
    mController.addListener(() {
      var index = mController.index;
      mController.animateTo(index);
      setState(() {
        tabStatus = tabList[index].status;
      });
      initTabData();
    });
  }

  // 监听返回
  Future<bool> _requestPop() {
    //跳转并关闭当前页面
    Navigator.pushAndRemoveUntil(
      context,
      new MaterialPageRoute(builder: (context) => new Index(cindex: 3)),
          (route) => route == null,
    );

    return new Future.value(false);
  }

  @override
  void dispose() {
    super.dispose();
    mController.dispose();
  }

  initTabData() async {
    setState(() {
      _showLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///参数
    var userid = prefs.getString('userId').toString();
    var formData = {'uid': userid,'status':tabStatus,'page':1,'pageNum':8};


    String secret_open = prefs.getString('secret_open');//1开 0关
    if(secret_open == '1') { //要加密
      lock(formData).then((params){
        formData = {'data':params};
        request('order_list_api', formData: formData).then((val) {
          var data = json.decode(val.toString());
          delock(data['data']).then((unlock_data){
            data['data'] = json.decode(unlock_data.toString());
            setState(() {
              orderList = data['data'];
              _showLoading = false;
            });
          });

        });
      });
    }

  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text('订单中心'),
            centerTitle: true,
          ),
          body: Container(
              color: Color.fromRGBO(245, 245, 245, 0.5),
              child: Column(
                children: <Widget>[
                  Container(
                    width: ScreenUtil().setWidth(750),
                    color: new Color.fromRGBO(245, 245, 245, 0.5),
                    height: 40.0,
                    child: TabBar(
                      isScrollable: false,
                      //是否可以滚动
                      controller: mController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Color(0xff666666),
                      labelStyle: TextStyle(fontSize: ScreenUtil().setSp(28)),
                      tabs: tabList.map((item) {
                        return Tab(
                          text: item.name,
                        );
                      }).toList(),
                    ),
                  ),
                  _showLoading ?
                  Center(
                    child: SpinKitThreeBounce(
                      color: Colors.lightGreen,
                      size: 50.0,
                      controller: AnimationController(
                          vsync: this,
                          duration: const Duration(milliseconds: 1200)),
                    ),
                  ) : Expanded(
                    child: TabBarView(
                      controller: mController,
                      children: tabList.map((item) {
                        if (orderList.length == 0) {
                          return Center(
                            child: Text('暂无数据'),
                          );
                        }
                        return Stack(
                          children: <Widget>[
                            ListView.builder(
                              itemCount: orderList.length,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                return orderItem(
                                    orderList[index],
                                    item.status,
                                    index);
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Widget orderItem(orderdetail, status, findex) {
    List goodsList = orderdetail['shop'];

    String status_str = '';
    switch (orderdetail['status'].toString()) {
      case "1":
        status_str = "待付款";
        break;
      case "2":
        status_str = "待发货";
        break;
      case "3":
        status_str = "待收货";
        break;
      case "4":
        status_str = "待评价";
        break;
//      case "5":
//        status_str = "已完成";
//        break;
//      case "6":
//        status_str = "已取消";
//        break;
//      case "10":
//        status_str = "售后";
//        break;
      default:
        status_str = "";
        break;
    }

    ///取消订单接口
    _cancelOrder() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ///参数
      var userid = prefs.getString('userId').toString();
      var formData = {'userid': userid, 'id': orderdetail['id']};
      request('cancelOrderPageContent', formData: formData).then((val) async {
        var data = json.decode(val.toString());
        if (data['code'] == 200) {}
        toast(data['message']);
        setState(() {});
      });
    }

    ///确认收货接口
    _sureOrder() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ///参数
      var userid = prefs.getString('userId').toString();
      var formData = {'userid': userid, 'id': orderdetail['id']};
      request('sureOrderPageContent', formData: formData).then((val) async {
        var data = json.decode(val.toString());
        if (data['code'] == 200) {}
        toast(data['message']);
        setState(() {});
      });
    }

    int index = 0;
    return Container(
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 5, right: 10, left: 10, top: 5),
      child: Column(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(650),
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Text(
                        orderdetail['dianpu_name'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(28)),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    status_str,
                    style: TextStyle(
                        color: Colors.blue, fontSize: ScreenUtil().setSp(28)),
                  ),
                )
              ],
            ),
          ),
          ListTile(
            leading: Image.network(goodsList[index]['goods_img']),
            title: Text(goodsList[index]['goods_name']),
            subtitle: Text(goodsList[index]['specid_name']),
            trailing: Column(
              children: <Widget>[
                Text(
                  '¥${goodsList[index]['goods_price']}',
                  style: TextStyle(color: Colors.red),
                ),
                Text(
                  'x${goodsList[index]['goods_num']}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
//              Navigator.push(
//                context,
//                MaterialPageRoute(
//                  builder: (context) =>
//                      OrderDetail(orderId: orderList[findex]['id']),
//                ),
//              );
            },
          ),
          Container(
            width: ScreenUtil().setWidth(650),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.library_books,
                        color: Colors.grey,
                        size: 20,
                      ),
                      Text(
                        '123',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: ScreenUtil().setSp(24)),
                      ),
                    ],
                  ),
                ),
                Text(
                  orderdetail['addtime'],
                  style: TextStyle(
                      color: Colors.grey, fontSize: ScreenUtil().setSp(24)),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 5, right: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  '共${orderdetail['totalNum']}件商品 合计:¥${orderdetail['totalprice']}',
                  style: TextStyle(
                      color: Colors.grey, fontSize: ScreenUtil().setSp(24)),
                )
              ],
            ),
          ),
          orderdetail['status']==1?Container(
            margin: EdgeInsets.only(right: 10),
            child: Align(
              alignment: FractionalOffset.topRight,
              child: MaterialButton(
                child: Text('取消订单'),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('是否确认取消订单'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('确认'),
                            onPressed: () {
                              _cancelOrder();
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text('取消'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                        // 设置成 圆角
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      );
                    },
                  );
                },
                color: Colors.blue,
                textColor: Colors.white,
                //触摸按钮时，类似水波纹扩散的颜色
                splashColor: Colors.orange,
                shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
              ),
            ),
          ):Container(),
          orderdetail['status']==3?Container(
            margin: EdgeInsets.only(right: 10),
            child: Align(
              alignment: FractionalOffset.topRight,
              child: MaterialButton(
                child: Text('确认收货'),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('是否确认确认收货'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('确认'),
                            onPressed: () {
                              _sureOrder();
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text('取消'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                        // 设置成 圆角
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      );
                    },
                  );
                },
                color: Colors.blue,
                textColor: Colors.white,
                //触摸按钮时，类似水波纹扩散的颜色
                splashColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
              ),
            ),
          ):Container(),
        ],
      ),
    );
  }
}
