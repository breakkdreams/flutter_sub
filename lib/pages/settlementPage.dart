import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/address_page.dart';

class SettlementPage extends StatefulWidget {
  Map settlementInfo;
  int is_car;
  SettlementPage({this.settlementInfo,this.is_car});
  _SettlementPageState createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> with TickerProviderStateMixin {
  TextEditingController _message_controller = new TextEditingController();
  int pay_way = 4;
  List shopList;
  Map defaultAddress;
  bool vistable = true;
  String totalnum = '0';
  String totalprice = '0';
  bool _showLoading = false;

  @override
  void initState() {
    setState(() {
      _showLoading = true;
    });
    getSettleInfo();
    super.initState();
  }

  getSettleInfo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    var formData = {'uid': userid};
    request('default_address_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      print(data);
      if (data['code'] == 200) {
        setState(() {
          defaultAddress = data['data'];
          vistable = false;
        });
      }
      setState(() {
        shopList = widget.settlementInfo['shops'] as List;
        totalnum = widget.settlementInfo['totalnum'].toString();
        totalprice = widget.settlementInfo['totalprice'].toString();
        _showLoading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('确认订单'),
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
        ) : Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      ListTile(
                        onTap: (){
                          Application.router.navigateTo(context, Routes.addressListPage+"?need_return=1").then((msg){
                            setState(() {
                              defaultAddress = msg;
                            });
                          });
                        },
                        leading: Icon(Icons.add_location),
                        title: vistable
                            ? Center(child: Text("请添加收货地址"))
                            : Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                '${defaultAddress['receive_name']} ${defaultAddress['receive_phone']}'),
                            SizedBox(height: 10),
                            Text(defaultAddress['address'])
                          ],
                        ),
                        trailing: Icon(Icons.navigate_next),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  child: Column(
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: shopList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _checkOutItem(shopList[index]);
                        },
                      )
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '商品数量: ${totalnum}',
                        style:
                        TextStyle(fontSize: ScreenUtil().setSp(28)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 10,right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: new Border.all(color: Colors.black, width: 0.5),
                  ),
                  child: TextField(
                    controller: _message_controller,
                    textInputAction: TextInputAction.done,
                    maxLines: 6,
                    decoration: InputDecoration.collapsed(hintText: "请输入留言"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(100)),
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Image.asset(
                          'assets/images/yue.png',
                          width: ScreenUtil().setSp(50),
                        ),
                        title: new Text('余额'),
                        selected: pay_way == 4 ? true : false,
                        trailing: new Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          setState(() {
                            pay_way = 4;
                          });
                        },
                      ),
                      ListTile(
                        leading: Image.asset(
                          'assets/images/wechat.png',
                          width: ScreenUtil().setSp(50),
                        ),
                        title: new Text('微信'),
                        selected: pay_way == 2 ? true : false,
                        trailing: new Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          setState(() {
                            pay_way = 2;
                          });
                        },
                      ),
                      ListTile(
                        leading: Image.asset(
                          'assets/images/ali.png',
                          width: ScreenUtil().setSp(50),
                        ),
                        title: new Text('支付宝'),
                        selected: pay_way == 1 ? true : false,
                        trailing: new Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          setState(() {
                            pay_way = 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              width: ScreenUtil().setWidth(750),
              height: ScreenUtil().setHeight(80),
              child: Container(
                width: ScreenUtil().setWidth(750),
                height: ScreenUtil().setHeight(100),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        top: BorderSide(
                            width: 1, color: Colors.black26))),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text("合计：￥${totalprice}",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: ScreenUtil().setSp(28))),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: ScreenUtil().setWidth(300),
                        height: ScreenUtil().setHeight(80),
                        child: RaisedButton(
                          child: Text("立即下单",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(28))),
                          color: Colors.red,
                          onPressed: () {
                            make_order();
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  make_order() async {
    var formData;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    if(widget.is_car == 1){
      String cids = '';
      for(var item in shopList){
        List itemList = item['cartinfo'];
        for(var shopItem in itemList){
          if(cids != ''){
            cids += ',';
          }
          cids += shopItem['cartid'].toString();
        }
      }
      formData = {'uid': userid,'city_id': defaultAddress['id'],'liuyan': _message_controller.text,'cids': cids};
    }else{
      String specid = '';
      if(shopList[0]['cartinfo'][0]['goodsspec'] != null){
        String specid = shopList[0]['cartinfo'][0]['goodsspec'];
        specid = specid.replaceAll('_', ',');
      }
      String gid = shopList[0]['cartinfo'][0]['goodsid'].toString();
      formData = {'uid': userid,'city_id': defaultAddress['id'],'liuyan': _message_controller.text,'specid': specid,'gid': gid,'num': totalnum};
    }
    request('make_order_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      if (data['code'] == 200) {
        String order_id = data['data']['order_id'];
        String ordersn = data['data']['ordersn'];

        String title = '';
        for(var items in shopList){
          for(var second_item in items['cartinfo']){
            if(title!=''){
              title += ',';
            }
            title+=second_item['goodsname'];
          }
        }
        var payment_formData = {'uid': userid,'sid': ordersn,'tid': pay_way,'title': title,'money': totalprice};
        request('add_payment_api', formData: payment_formData).then((second_val) {
          var second_data = json.decode(second_val.toString());
          if (second_data['code'] == 200) {
            String out_trade_no = second_data['data'];
            if(pay_way == 4){
              TextEditingController _textEditingController = new TextEditingController();
              showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: Text('请输入支付密码'),
                      content: Card(
                        elevation: 0.0,
                        child: Column(
                          children: <Widget>[
                            TextField(
                              controller: _textEditingController,
                              obscureText:true,
                              autofocus: true,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade50),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.pop(context);
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: Text('取消'),
                        ),
                        CupertinoDialogAction(
                          onPressed: () {
                            var third_formData = {'uid': userid, 'out_trade_no': out_trade_no,'password':_textEditingController.text};
                            request('balance_api', formData: third_formData).then((third_val) async {
                              var third_data = json.decode(third_val.toString());
                              if (third_data['code'] == 200)  {

                              }
                              _textEditingController.clear();
                              Navigator.pop(context);
                              FocusScope.of(context).requestFocus(FocusNode());
                              toast(third_data['message']);
                            });
                          },
                          child: Text('确定'),
                        ),
                      ],
                    );
                  });
            }else if(pay_way == 2){
              toast('下单成功,暂未开发微信支付');
            }else if(pay_way == 1){
              toast('下单成功,暂未开发支付宝支付');
            }
          }
        });

      }
    });
  }

  Widget _checkOutItem(shopMap) {
    List goodsList = shopMap['cartinfo'];
    return Column(
      children: <Widget>[
        Container(
          width: ScreenUtil().setWidth(750),
          padding: EdgeInsets.only(left: 10,bottom: 10),
          child: Row(
            children: <Widget>[
              Text(
                shopMap['shopname'],style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                height: 1.5
              ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: goodsList.length,
          itemBuilder: (BuildContext context, int index) {
            return _goodsItem(goodsList[index]);
          },
        ),
      ],
    );
  }

  Widget _goodsItem(goodsMap) {
    return Row(
      children: <Widget>[
        Container(
          width: ScreenUtil().setWidth(160),
          child: Image.network(goodsMap['goodsimg']),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    goodsMap['goodsname'],
                    maxLines: 2,
                    style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                  ),
                ),
                goodsMap['goodsspecs']!=''?Container(
                 margin: EdgeInsets.only(top: 10),
                 decoration: BoxDecoration(
                     border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                 ),
                 child:  Container(
                   padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                   child: Text(
                     goodsMap['goodsspecs'],
                     maxLines: 1,
                     style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Colors.red,),
                   ),
                 ),
               ):Container(),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child:  Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("￥${goodsMap['goodsprice']}",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: ScreenUtil().setSp(28))),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'x${goodsMap['cartnum']}',
                          style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                        ),
                      )
                    ],
                  )
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
