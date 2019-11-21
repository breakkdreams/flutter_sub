import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/pages/settlementPage.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/data_service.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPagetState createState() => _CartPagetState();
}

class _CartPagetState extends State<CartPage> with TickerProviderStateMixin  {
  List cartList = new List();
  bool allcheck = false;
  Map final_map = {"final_price":"0" , "final_counts":"0"};
  ///显示加载动画
  bool _showLoading = false;

  @override
  void initState() {
    setState(() {
      final_map["final_price"] = "0";
      final_map["final_counts"] = "0";
      _showLoading = true;
    });
    ///获取列表记录
    getCartList();
    super.initState();
  }


  getCartList() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    var formData = {'uid': userId};


    String secret_open = prefs.getString('secret_open');//1开 0关
    if(secret_open == '1') { //要加密
      lock(formData).then((params){
        formData = {'data':params};
        request('cart_list_api', formData: formData).then((val) {
          var data = json.decode(val.toString());
          delock(data['data']).then((unlock_data){
            data['data'] = json.decode(unlock_data.toString());
            setState(() {
              cartList = data['data']['data']['carts'];
              setState(() {
                _showLoading = false;
              });
            });
          });

        });
      });
    }
  }

  ///购物车数量加减
  carOpera(cid,specid,nums) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    var formData = {'uid': userId,'cid':cid,'specid':specid,'num':nums};
    request('cart_opera_api', formData: formData).then((val) async {
      var data = json.decode(val.toString());
    });
  }


  ///购物车删除
  carDeleted(cid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    var formData = {'uid': userId,'cids':cid};
    request('cart_deleted_api', formData: formData).then((val) async {
      var data = json.decode(val.toString());
      toast(data['message']);
      getCartList();
    });
  }

  ///跳转到预下单
  _page_settlement() async {
    String cids = '';
    for(var item in cartList){
      List itemList = item['cartinfo'];
      for(var shopItem in itemList){
        if(shopItem['check_one']){
          if(cids != ''){
            cids += ',';
          }
          cids += shopItem['cartid'].toString();
        }
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    var formData = {'uid': userid,'cids':cids};
    request('cart_settlement_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      if (data['code'] == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SettlementPage(settlementInfo: data['data']['data'],is_car:1)
            )
        ).then((msg){
          getCartList();
        });
      }
      toast(data['message']);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('购物车'),
        centerTitle: true,
      ),
      body: _showLoading?
      Center(
        child: SpinKitThreeBounce(
          color: Colors.lightGreen,
          size: 50.0,
          controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
        ),
      ) : cartList.length<1? Center(
        child: Container(
          child: Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
            child: Image.asset('assets/images/empty_data.png'),
          ),
        ),
      ) : Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: cartList.length,
            itemBuilder: (BuildContext context, int index) {
              return _CartItem(cartList[index],index);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _CartBottom(),
          )
        ],
      ),
    );
  }

  ///获取商品列表UI
  Widget _CartItem(maps,findex){
    List list = maps['cartinfo'];
    return Container(
      child: Column(
        children: <Widget>[
          Container(
              width: 400,
              margin: EdgeInsets.fromLTRB(5.0, 0, 0, 0),
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Text(
                    maps['shopname'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(28)),
                  ),
                ],
              )),
          Container(
            height: list.length * 100.0,
            child: ListView.builder(
              physics: new NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return Slidable(
                  secondaryActions: <Widget>[
                    new IconSlideAction(
                        caption: '删除',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: (){
                          carDeleted(list[index]['cartid']);
                        }),
                  ],
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5.0, 0, 5.0, 2.0),
                    padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            _cartCheckBt(list[index],index,findex),
                            _cartImage(list[index]),
                            _cartGoodsName(list[index]),
                            _cartPrice(list[index],findex,index)
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  ///购物车按钮
  Widget _CartBottom(){
    return Container(
      margin: EdgeInsets.all(5.0),
      color: Colors.white,
      width: ScreenUtil().setWidth(750),
      child: Row(
        children: <Widget>[selectAllBtn(), allPriceArea(), goButton()],
      ),
    );
  }

  //全选按钮
  Widget selectAllBtn() {
    return Container(
      child: Row(
        children: <Widget>[
          Checkbox(
            value: this.allcheck,
            activeColor: Colors.red,
            onChanged: (bool val) {
              setState(() {
                this.allcheck = val;
              });
              for(var i = 0;i < cartList.length;i++){
                for(var j = 0;j < cartList[i]['cartinfo'].length;j++){
                  cartList[i]['cartinfo'][j]['check_one'] = val;
                }
              }
              _calculation();
            },
          ),
          Text('全选')
        ],
      ),
    );
  }

  ///计算价格
  _calculation(){
    double final_price = 0.0;
    int final_counts = 0;
    for(var i = 0;i < cartList.length;i++){
      for(var j = 0;j < cartList[i]['cartinfo'].length;j++){
        if(cartList[i]['cartinfo'][j]['check_one']){
          final_price += (double.parse(cartList[i]['cartinfo'][j]['goodsprice']) * double.parse(cartList[i]['cartinfo'][j]['cartnum'].toString()));
          final_counts += int.parse(cartList[i]['cartinfo'][j]['cartnum'].toString());
        }
      }
    }
    setState(() {
      final_map["final_price"] = final_price.toStringAsFixed(2);
      final_map["final_counts"] = final_counts.toString();
    });
  }

  // 合计区域
  Widget allPriceArea() {
    return Container(
      width: ScreenUtil().setWidth(430),
      alignment: Alignment.centerRight,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                alignment: Alignment.centerRight,
                width: ScreenUtil().setWidth(280),
                child: Text('合计:',
                    style: TextStyle(fontSize: ScreenUtil().setSp(28))),
              ),
              Container(
                margin: EdgeInsets.only(top:5),
                alignment: Alignment.centerLeft,
                width: ScreenUtil().setWidth(150),
                child: Text(final_map['final_price'],
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      color: Colors.red,
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }

  //多选按钮
  Widget _cartCheckBt(item,index,findex) {
    return Container(
      child: Checkbox(
        value: cartList[findex]['cartinfo'][index]['check_one'],
        activeColor: Colors.red,
        onChanged: (bool val) {
          setState(() {
            cartList[findex]['cartinfo'][index]['check_one'] = val;
          });
          _calculation();
          _changeAllCheck();
        },
      ),
    );
  }

  ///更改多选来修改全选按钮的状态
  _changeAllCheck(){
    int is_false = 0;
    for(var i = 0;i < cartList.length;i++){
      for(var j = 0;j < cartList[i]['cartinfo'].length;j++){
        if(!cartList[i]['cartinfo'][j]['check_one']){
          is_false = 1;
          setState(() {
            this.allcheck = false;
          });
        }
      }
    }
    if(is_false == 0){
      setState(() {
        this.allcheck = true;
      });
    }
  }

  //商品图片
  Widget _cartImage(item) {
    return Container(
      width: ScreenUtil().setWidth(150),
      padding: EdgeInsets.all(3.0),
      decoration:
          BoxDecoration(border: Border.all(width: 1, color: Colors.black12)),
      child: Image.network(
        item['goodsimg'],
        fit: BoxFit.fill,
        width: ScreenUtil().setWidth(200),
        height: ScreenUtil().setHeight(100),
      ),
    );
  }

  //商品名称
  Widget _cartGoodsName(item) {
    return Container(
      width: ScreenUtil().setWidth(250),
      padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
      alignment: Alignment.topLeft,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Text(item['goodsname']),
          ),
          Text('￥${item['goodsprice']}'),
        ],
      ),
    );
  }

  //商品价格
  Widget _cartPrice(item,findex,index) {
    return Container(
      width: ScreenUtil().setWidth(200),
      alignment: Alignment.centerRight,
      child: Column(
        children: <Widget>[_CartCount(item,findex,index)],
      ),
    );
  }

  ///结算按钮
  Widget goButton() {
    String cartid = '';
    for(var i = 0;i < cartList.length;i++){
      for(var j = 0;j < cartList[i]['cartinfo'].length;j++){
        if(cartList[i]['cartinfo'][j]['check_one']){
          if(cartid!=''){
            cartid += ',';
          }
          cartid += cartList[i]['cartinfo'][j]['cartid'].toString();
        }
      }
    }
    return Container(
      width: ScreenUtil().setWidth(160),
      padding: EdgeInsets.only(left: 10),
      child: InkWell(
        onTap: () {
          if(cartid ==''){
           toast('请选择商品');
           return;
          }
          _page_settlement();
        },
        child: Container(
          padding: EdgeInsets.all(10.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(3.0)),
          child: Text(
            '结算('+final_map['final_counts']+')',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _CartCount(item,findex,index){
    return Container(
      width: ScreenUtil().setWidth(165),
      margin: EdgeInsets.only(top: 5.0),
      decoration:
      BoxDecoration(border: Border.all(width: 1, color: Colors.black12)),
      child: Row(
        children: <Widget>[
          _reduceBtn(item,findex,index),
          _countArea(item['cartnum']),
          _addBtn(item,findex,index),
        ],
      ),
    );
  }

  // 减少按钮
  Widget _reduceBtn(item,findex,index) {
    return InkWell(
      onTap: (){
        if(int.parse(item['cartnum'].toString())-1 < 1){
          toast('数量不能少于1');
          return;
        }
        setState(() {
          carOpera(item['cartid'],item['goodsspec'],(int.parse(item['cartnum'].toString())-1).toString());
          cartList[findex]['cartinfo'][index]['cartnum'] = (int.parse(item['cartnum'].toString())-1).toString();
        });
        _calculation();
      },
      child: Container(
        width: ScreenUtil().setWidth(45),
        height: ScreenUtil().setHeight(45),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(width: 1, color: Colors.black12))),
        child: Text('-'),
      ),
    );
  }

  //添加按钮
  Widget _addBtn(item,findex,index) {
    return InkWell(
      onTap: () {
        setState(() {
          carOpera(item['cartid'],item['goodsspec'],(int.parse(item['cartnum'].toString())+1).toString());
          cartList[findex]['cartinfo'][index]['cartnum'] = (int.parse(item['cartnum'].toString())+1).toString();
        });
        _calculation();
      },
      child: Container(
        width: ScreenUtil().setWidth(45),
        height: ScreenUtil().setHeight(45),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(width: 1, color: Colors.black12))),
        child: Text('+'),
      ),
    );
  }

  //中间数量显示区域
  Widget _countArea(counts) {
    return Container(
      width: ScreenUtil().setWidth(70),
      height: ScreenUtil().setHeight(45),
      alignment: Alignment.center,
      color: Colors.white,
      child: Text(counts.toString()),
    );
  }
}