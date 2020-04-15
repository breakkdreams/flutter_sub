import 'package:flutter/material.dart';
import 'package:flutter_sub/pages/cartPage.dart';
import 'package:flutter_sub/pages/categoryPage.dart';
import '../pages/personalPage.dart';
import '../provide/login_provide.dart';
import 'package:provide/provide.dart';
import 'homePage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class Index extends StatelessWidget {
  final int cindex;
  Index({Key key,@required this.cindex}):super(key:key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Homes(cindex),
    );
  }
}

class Homes extends StatefulWidget {
  final int cindex;
  Homes(this.cindex);
  @override
  State<StatefulWidget> createState() {
    return _HomesState(cindex);
  }
}
class _HomesState extends State<Homes> {
  int _currentIndex = 0;
  final int cindex;
  _HomesState(this.cindex);
  final List<Widget> _children = [HomePage(), CategoryPage(), CartPage(), PersonalPage()];

  final List<BottomNavigationBarItem> _list = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      title: Text('首页'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.category),
      title: Text('分类'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add_shopping_cart),
      title: Text('购物车'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_circle),
      title: Text('我的'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    if(cindex!=null){
      setState(() {
        _currentIndex = cindex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: _list,
      ),
      body: _children[_currentIndex],
    );
  }

  void onTabTapped(int index){
    setState(() {
      _currentIndex = index;
    });
  }
}
