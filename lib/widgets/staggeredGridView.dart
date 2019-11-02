
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sub/routers/application.dart';
import 'package:flutter_sub/routers/routes.dart';

class Waterfall extends StatelessWidget {
  List goodsList;
  Waterfall(this.goodsList);
  @override
  Widget build(BuildContext context) {
    return _StaggeredGridView(context);
  }
  Widget _StaggeredGridView(context){
    return StaggeredGridView.countBuilder(
      shrinkWrap: true,
      physics: new NeverScrollableScrollPhysics(),
      itemCount: goodsList.length,
      primary: false,
      crossAxisCount: 4,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      itemBuilder: (context, index) => _tileCard(goodsList[index],context),
      staggeredTileBuilder: (index) => StaggeredTile.fit(2),
    );
  }

  Widget _tileCard(Map goodsMap,context){
    return GestureDetector(
      onTap: (){
        Application.router.navigateTo(context, Routes.goodsDetailPage+"?id=${goodsMap['id'].toString()}");
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/empty.png',
                image: goodsMap['goodsimg'],
                fit: BoxFit.fitHeight,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
              margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
              child: Text(
                goodsMap['goodsname'],
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(5),
                  bottom: ScreenUtil().setWidth(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                    width: ScreenUtil().setWidth(120),
                    child: Text(
                      '¥${goodsMap['shopprice']}',
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          color: Colors.red
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                    width: ScreenUtil().setWidth(80),
                    child: Text(
                      '销量:${goodsMap['salenum']}',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(23),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}




