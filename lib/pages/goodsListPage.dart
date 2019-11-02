import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/delivery_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/phoenix_footer.dart';
import 'package:flutter_easyrefresh/phoenix_header.dart';
import 'package:flutter_easyrefresh/taurus_footer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoodsListPage extends StatefulWidget {
  String catid;
  var sercon;
  GoodsListPage({this.catid,this.sercon});

  @override
  _GoodsListPageState createState() => _GoodsListPageState();
}

class _GoodsListPageState extends State<GoodsListPage> with TickerProviderStateMixin {

  var tabController;

  ///显示加载动画
  bool _showLoading = false;
  List goodsList;

  @override
  void initState() {
    super.initState();
    setState(() {
      _showLoading = true;
    });
    this.tabController = new TabController(
      vsync: this,        // 动画效果的异步处理
      length: 4,        // tab 个数
      initialIndex: 0   // 起始位置
    );

    this.tabController.addListener(() {
      if (this.tabController.indexIsChanging) {
        print('索引改变');
      }
    });
    _init();
  }
  int page = 1;
  int paginate = 6;
  bool is_refresh = false;

  void _init() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///参数
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid,"page":page,"paginate":paginate,"order":1};
    if(widget.catid !=null && widget.catid!=''){
      formData['catid'] = widget.catid;
    }if(widget.sercon !=null && widget.sercon!=''){

      var list = List<int>();
      ///字符串解码
      jsonDecode(widget.sercon).forEach(list.add);
      final String value = Utf8Decoder().convert(list);
      formData['sercon'] = value;
    }
    request('goods_list_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      print(data);
      if (data['code'] == 200) {
        setState(() {
          _showLoading = false;
          if(is_refresh){
            goodsList.addAll(data['data']['data']);
          }else{
            goodsList = data['data']['data'];
          }
        });
      }else{
        toast(data['message']);
      }
    });
  }

  ///刷新
  _refresh_init(){
    setState(() {
      page = 1;
      paginate = 6;
      is_refresh = false;
    });
    _init();
  }
  ///加载更多
  _get_more(){
    setState(() {
      page = page+1;
      is_refresh = true;
    });
    _init();
  }

  @override
  void dispose() {
    this.tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商品列表'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search,color: Colors.white,),
          )
        ],
          bottom: new TabBar(
            controller: this.tabController,
            indicatorColor: Colors.transparent,
            unselectedLabelColor: Colors.blue[200],
            labelColor: Colors.white,
            tabs: <Tab>[
              new Tab(text: '综合'),
              new Tab(text: '价格'),
              new Tab(text: '销量'),
              new Tab(text: '新品'),
            ],
          )
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
            EasyRefresh(
              header: PhoenixHeader(),
              footer: TaurusFooter(),
              onRefresh: () async {
                _refresh_init();
              },
              onLoad: () async {
                _get_more();
              },
              child: goodsList.length<1?Center(
                child: Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
                  child: Image.asset('assets/images/empty_data.png'),
                ),
              ): ListView.builder(
                itemCount: goodsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return _goodsItem(goodsList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///商品列表
  Widget _goodsItem(goodsItem){
    return ListTile(
      contentPadding: EdgeInsets.all(20),
      leading: FadeInImage.assetNetwork(
        placeholder: 'assets/images/empty.png',
        image: goodsItem['goodsimg'],
        width: ScreenUtil().setWidth(120),
        fit: BoxFit.fitHeight,
      ),
      title: Text(goodsItem['goodsname'],style: TextStyle(
        fontSize: ScreenUtil().setSp(28)
      ),),
      subtitle: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(top: 20),
//              width: ScreenUtil().setWidth(750),
                  child: Text("¥${goodsItem['shopprice']}",style: TextStyle(
                      color: Colors.red,
                      fontSize: ScreenUtil().setSp(30)
                  ),)
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text('  ${goodsItem['salenum'].toString()}人付款',
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(

                  ),),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                Text(goodsItem['shopname']),
                Icon(Icons.keyboard_arrow_right,color: Color.fromRGBO(153,153,153,1),size: 18,)
              ],
            ),
          )
        ],
      ),
      onTap: () {
        Application.router.navigateTo(context, Routes.goodsDetailPage+"?id=${goodsItem['id'].toString()}");
      },
    );
  }
}
