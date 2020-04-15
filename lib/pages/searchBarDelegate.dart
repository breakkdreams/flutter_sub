import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/pages/search_suggest_page.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/widgets/gzx_search_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchGoodsPage extends StatefulWidget {
  final String keywords;
  const SearchGoodsPage({Key key, this.keywords}) : super(key: key);

  @override
  _SearchGoodsPageState createState() => _SearchGoodsPageState();
}

class _SearchGoodsPageState extends State<SearchGoodsPage> with TickerProviderStateMixin {
  List<String> recomendWords = [];
  TextEditingController _keywordsTextEditingController = TextEditingController();
  bool _showLoading = false;
  List historyList = new List();

  @override
  void initState() {
    super.initState();
    _keywordsTextEditingController.text = widget.keywords;
    if (widget.keywords != null) {
      seachTxtChanged(widget.keywords);
    }
    _init();
  }

  _init() async {
    setState(() {
      _showLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString('userId').toString();
    var formData = {"uid": userid};
    request('search_history_api', formData: formData).then((val) async {
      var data = json.decode(val.toString());
      print(data);
      if (data['code'] == 200) {
        historyList = data['data'];
        setState(() {
          _showLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: Container(
          child: AppBar(
            elevation: 0.0,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(0,167,255,1),
                Color.fromRGBO(102,199,250,1)
              ],
            ),
          ),
        ),
        preferredSize:  Size.fromHeight(0),
      ),
      body: DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(0,167,255,1),
                      Color.fromRGBO(102,199,250,1)
                    ],
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      flex: 1,
                      child: GZXSearchCardWidget(
                        elevation: 0,
                        autofocus: true,
                        textEditingController: _keywordsTextEditingController,
                        isShowLeading: false,
                        onSubmitted: (value) {
                          seachTxtChanged(value);
                        },
                      ),
                    ),
                    GestureDetector(
                      child: Text(
                        '  取消',
                        style: TextStyle(fontSize: ScreenUtil().setSp(28),color:Colors.white,),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      width: 8,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                width: ScreenUtil().setHeight(750),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(4.0),topRight: Radius.circular(4.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('历史搜索',style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.bold
                    ),),
                    Icon(Icons.delete)
                  ],
                ),
              ),
              _showLoading?
              Center(
                child: SpinKitThreeBounce(
                  color: Colors.lightGreen,
                  size: 50.0,
                  controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
                ),
              ) : Container(
                width: ScreenUtil().setHeight(750),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(4.0),topRight: Radius.circular(4.0)),
                ),
                child: _history(),
              ),
            ],
          )),
    );
  }

  Widget _history(){
    return Container(
      padding: EdgeInsets.only(left: 20,right: 20),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 10.0,
          runSpacing: 8.0,
          children: Boxs(),
        ),
      ),
    );
  }

  List<Widget> Boxs() => List.generate(historyList.length, (index) {
    return Container(
      padding: EdgeInsets.fromLTRB(7, 5, 7, 5),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.red),
          borderRadius: BorderRadius.circular(8.0)),
      child: GestureDetector(
        onTap: (){
          seachTxtChanged(historyList[index]);
        },
        child: Text(historyList[index]),
      ),
    );
  });


  void seachTxtChanged(q) async {
    var sercon = Utf8Encoder().convert(q);
    Navigator.of(context).pop();
    Application.router.navigateTo(context, Routes.goodsListPage+"?sercon=${sercon}&catid=");
  }
}