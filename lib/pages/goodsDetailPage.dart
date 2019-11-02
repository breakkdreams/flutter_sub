import 'dart:collection';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/model/settlementModel.dart';
import 'package:flutter_sub/pages/settlementPage.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/data_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../pages/index_page.dart';

class GoodsDetailPage extends StatefulWidget {
  final String goods_id;

  GoodsDetailPage({this.goods_id});

  @override
  _GoodsDetailPageState createState() => _GoodsDetailPageState(goods_id);
}

class _GoodsDetailPageState extends State<GoodsDetailPage> with TickerProviderStateMixin {
  final String goodsId;

  _GoodsDetailPageState(this.goodsId);

  List attrList = new List();
  List specList = new List();
  Map checkedMap = new HashMap();//选中的属性
  List swiperList= [];
  Map goodsInfo = {};
  bool is_collection = false;
  List goods_detail_list = new List();


  Map skuData = new Map();

  ///数字
  int num = 1;

  ///显示加载动画
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _showLoading = true;
    });
    _init();
  }

  _init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///参数
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid,"id":goodsId};
    request('goods_info_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      if (data['code'] == 200) {
        setState(() {
          _showLoading = false;
          ///是否收藏
          if(data['data']['issc'] == 1){
            is_collection = true;
          }else{
            is_collection = false;
          }
          ///轮播图
          swiperList = data['data']['goodsalbum'];
          ///商品详情
          goodsInfo = data['data'];
          ///商品详情图
          goods_detail_list = data['data']['goodsinfo'];
        });
      }else{
        toast(data['message']);
      }
    });
    ///添加足迹
    var footFormData = {"uid": userid,"goods_id":goodsId,"type":1};
    request('footprint_api', formData: footFormData).then((val) {
      var data = json.decode(val.toString());
    });
    ///获取商品配置
    var specFormData = {"id":goodsId};
    request('goods_spec_api', formData: specFormData).then((val) {
      var data = json.decode(val.toString());
      skuData = data['data']['skuData'];

      attrList = skuData['sku']['tree'];
      if(attrList!=null && attrList.length>0){
        for(var items in attrList){
          items['checkVal'] = 0;
          setState(() {
            attrList = attrList;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  _showLoading ?
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
            padding: EdgeInsets.all(5.0),
            children: <Widget>[
              SwiperIndex(swiperList: swiperList),
              PriceAndGoodsName(goodsInfo),
              Container(
                color: Colors.white,
                child: ListTile(
                  leading: Text('商品规格:',style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                  ),),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    _attrBottomSheet(skuData);
                  },
                ),
              ),
              Container(
                color: Colors.white,
                child: ListTile(
                  leading: Text('商品评价:',style: TextStyle(
                      fontSize: ScreenUtil().setSp(28)
                  ),),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    _attrBottomSheet(skuData);
                  },
                ),
              ),
              ///评价
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          ClipOval(
                            child: Image.asset('assets/images/empty.png',width: ScreenUtil().setWidth(100),),
                          ),
                          Text('  生***张',style: TextStyle(
                            fontSize: ScreenUtil().setSp(28)
                          ),)
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text('宝贝很好,又是超薄款,比我以前买的扫地机器人强!宝贝很好,又是超薄款,比我以前买的扫地机器人强!宝贝很好,又是超薄款,比我以前买的扫地机器人强!',style: TextStyle(
                        fontSize: ScreenUtil().setSp(28)
                      ),),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20,bottom: 10),
                child: Text(
                  '商品详情',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(32),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(80)),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: new NeverScrollableScrollPhysics(),
                  itemCount: goods_detail_list.length,
                  padding: new EdgeInsets.all(10.0),
                  itemBuilder: (BuildContext context,int index){
                    return FadeInImage.assetNetwork(
                      placeholder: 'assets/images/empty.png',
                      image: goods_detail_list[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              )
            ],
          ),
          ///顶部返回按钮
          Positioned(
            top: MediaQueryData.fromWindow(window).padding.top,
            left: 20.0,
            child:Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.5),
                borderRadius:BorderRadius.circular(50.0),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          ///底部ui
          Positioned(
            bottom: 0,
            child: Container(
            height: ScreenUtil().setHeight(80),
              color: Colors.white,
              width: ScreenUtil().setWidth(750),
              child: Row(
                children: <Widget>[
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          width: ScreenUtil().setWidth(150),
                          child: IconButton(icon: is_collection?Icon(Icons.favorite):Icon(Icons.favorite_border),color: Colors.red, onPressed: () {
                            _addCollection(goodsId);
                            setState(() {

                            });
                          },),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(150),
                          child: IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Index(cindex:2),
                              ),
                            );
                          },),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(225),
                          child: MaterialButton(
                            color: Colors.orange,
                            textColor: Colors.white,
                            child: new Text('加入购物车',style: TextStyle(
                              fontSize: ScreenUtil().setSp(28)
                            ),),
                            onPressed: () {
                              _attrBottomSheet(skuData);
                            },
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(225),
                          child: MaterialButton(
                            color: Colors.red,
                            textColor: Colors.white,
                            child: new Text('立即购买',style: TextStyle(
                                fontSize: ScreenUtil().setSp(28)
                            ),),
                            onPressed: () {
                              _attrBottomSheet(skuData);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _attrBottomSheet(skuData) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, state) {
                return GestureDetector(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: ListTile(
                            leading: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/empty.png',
                              image: skuData['goods_info']['picture'],
                              width: ScreenUtil().setWidth(120),
                              height: ScreenUtil().setWidth(120),
                              fit: BoxFit.fill,
                            ),
                            title: Text(skuData['goods_info']['title'],style: TextStyle(fontSize: ScreenUtil().setSp(28),),),
                            subtitle: Text('¥:${skuData['sku']['price']}',style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Colors.red),),
                            trailing: Text('库存:${skuData['sku']['stock_num']}件'),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 70),
                          padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                          child: ListView(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Wrap(
                                    children: Boxs(attrList,state),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 100,
                          width: ScreenUtil().setWidth(750),
                          child: btn(state),
                        ),
                        Positioned(
                          bottom: 0,
                          width: ScreenUtil().setWidth(750),
                          height: ScreenUtil().setHeight(80),
                          child: Row(
                            children: <Widget>[
                              Container(
                                  width: ScreenUtil().setWidth(750),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: ScreenUtil().setHeight(80),
                                          child: MaterialButton(
                                            color: Color.fromRGBO(255,151,106,1),
                                            child: new Text('加入购物车',style: TextStyle(color: Colors.white,fontSize: ScreenUtil().setSp(28)),),
                                            onPressed: () {
                                              _addCart();
                                            },
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                            height: ScreenUtil().setHeight(80),
                                            child: MaterialButton(
                                              color: Color.fromRGBO(255,68,68, 1),
                                              child: new Text('立即购买',style: TextStyle(color: Colors.white,fontSize: ScreenUtil().setSp(28)),),
                                              onPressed: () {
                                                _buyNow();
                                              },
                                            ),
                                          ))
                                    ],
                                  ))
                            ],
                          ),
                        )
                      ],
                    ));
              });
        }).then((val){
          setState(() {
            checkedMap = checkedMap;
          });
    });
  }

  ///---------------------------- 各种点击方法sart--------------------------

  //加入购物车
  _addCart() async {
    String sarr = '';
    for(var item in attrList){
      if(sarr != ''){
        sarr += ',';
      }
      sarr = sarr + item['checkVal'];
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///参数
    var userid = prefs.getString('userId').toString();
    var formData = {'uid': userid,'id':goodsId,'sarr':sarr,'num':num};
    request('add_cart_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      if (data['code'] == 200) {
        Navigator.of(context).pop();
      }
      toast(data['message']);
    });
  }

  //立即购买
  _buyNow() async {
    String sarr = '';
    for(var item in attrList){
      if(sarr != ''){
        sarr += ',';
      }
      sarr = sarr + item['checkVal'];
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///参数
    var userid = prefs.getString('userId').toString();
    var formData = {'uid': userid,'gid':goodsId,'specid':sarr,'num':num};
    request('buy_now_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      if (data['code'] == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SettlementPage(settlementInfo: data['data']['data'],is_car:0)));
      }
      toast(data['message']);
    });
  }

  //添加收藏
  _addCollection(goodsId){
//    var formData = {'userid': loginProvide.user_id, 'type': 2,'id':goodsId};
//    request('addCollectionPageContent', formData: formData).then((val) async {
//      var data = json.decode(val.toString());
//      if (data['code'] == 1)  {
//
//      }else{
//        toast(data['message']);
//      }
//    });
  }

  //添加足迹
  _addFootprint(goodsId,userid){
    var formData = {'userid': userid, 'type': 2,'id':goodsId};
    request('addFootprintPageContent', formData: formData).then((val) async {
      var data = json.decode(val.toString());
      if (data['code'] == 1)  {

      }
    });
  }
  ///---------------------------- 各种点击方法end--------------------------

  ///按钮
  Widget btn(state) {
    return Container(
      width: 300,
      height: 50,
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Color(0x33333333)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Align(
              child: Text(
                '数量:  $num',
                style: TextStyle(color: Color(0xff333333), fontSize: 20),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              new GestureDetector(
                child: Container(
                  width: 50,
                  height: 30,
                  child: Icon(Icons.remove),
                ),
                //不写的话点击起来不流畅
                onTap: () {
                  if (num <= 0) {
                    return;
                  }
                  num--;
                  state(() => num = num);
                },
                onTapDown: (e) {
                  if (num <= 0) {
                    return;
                  }
                },
              ),
              new GestureDetector(
                child: Container(
                  width: 50,
                  height: 30,
                  child: Icon(Icons.add),
                ),
                onTap: () {
                  if (num >= 999) {
                    return;
                  }
                  num++;
                  state(() => num = num);
                },
                onTapDown: (e) {
                  if (num >= 999) {
                    return;
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }


  List<Widget> Boxs(attrList,state) =>
      List.generate(attrList.length, (index) {
        return Container(
            child: Row(
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(100),
              child: Text(attrList[index]['k'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              width: ScreenUtil().setWidth(610),
              child: Wrap(
                children: BoxsItem(index,attrList[index]['v'],attrList[index]['checkVal'],state),
              ),
            ),
          ],
        ));
      });

  List<Widget> BoxsItem(indexs,itemList,checkVal,state) =>
      List.generate(itemList.length, (index) {
        return GestureDetector(
          onTap: (){
            _attrCheck(indexs,index,itemList[index]['id'].toString());
            state(() {
              attrList = attrList;
            });
          },
          child: Container(
            margin: EdgeInsets.all(10),
            child: Chip(
              backgroundColor: checkVal==(itemList[index]['id'].toString()) ? Color.fromRGBO(255,68,68,1) : Colors.black12,
              label: Text(itemList[index]['name'].toString(),style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil().setSp(26)
              ),),
              padding: EdgeInsets.all(10),
            ),
          ),
        );
      });

  //获取选中的属性
  _attrCheck(indexs,item_index,id){
    attrList[indexs]['checkVal'] = id;
    String imgurl = attrList[indexs]['v'][item_index]['imgUrl'];
    if(imgurl !=null){
      skuData['goods_info']['picture'] = imgurl;
    }
    attrList[indexs]['k_v']=id.toString();

    ///属性选择完成
    List allSkuList = skuData['sku']['list'];
    if(allSkuList!=null && allSkuList.length>0){
      for(var items in allSkuList){
        items['is_check'] = 0;
      }
      for(var items in allSkuList){
        for(var itm in attrList){
          if(items['is_check'] == 0){
            if(items[itm['k_s']] == itm['k_v']){
              items['is_check'] = 0;
            }else{
              items['is_check'] = 1;
            }
          }
        }
      }
    }
    ///allSkuList['is_check'] == 0为中
    for(var items in allSkuList){
      if(items['is_check'] == 0){
        ///库存
        skuData['sku']['stock_num'] = items['stock_num'];
        skuData['sku']['price'] = items['price'];
      }
    }
  }
}


//轮播图
class SwiperIndex extends StatelessWidget {
  final List swiperList;

  SwiperIndex({Key key, this.swiperList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: ScreenUtil().setHeight(600),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemCount: swiperList.length,
        // 展示数量
        scrollDirection: Axis.horizontal,
        // 方向 Axis.horizontal  Axis.vertical
        autoplay: false,
        // 自动翻页
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {},
            child:FadeInImage.assetNetwork(
              placeholder: 'assets/images/empty.png',
              image: swiperList[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}

//价格和商品名称
class PriceAndGoodsName extends StatelessWidget {
  final Map goodsInfo;

  PriceAndGoodsName(this.goodsInfo);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(750),
            child: Text(
              goodsInfo['goodsname'],
              style: TextStyle(
                height: 1,
                fontSize: ScreenUtil().setSp(32),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                Container(
                  child: Text(
                    "¥${goodsInfo['shopprice']}",
                    style: TextStyle(
                      height: 1.5,
                      fontSize: ScreenUtil().setSp(30),
                      color: Colors.red,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    "¥${goodsInfo['marketprice']}",
                    style: TextStyle(
                      height: 1.5,
                      fontSize: ScreenUtil().setSp(28),
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Row(
              children: <Widget>[
                Container(
                  child: Text(
                    "运费: 免运费",
                    style: TextStyle(
                      height: 1.5,
                      fontSize: ScreenUtil().setSp(25),
                      color: Colors.grey,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    "销量: ${goodsInfo['salenum']}",
                    style: TextStyle(
                      height: 1.5,
                      fontSize: ScreenUtil().setSp(25),
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
