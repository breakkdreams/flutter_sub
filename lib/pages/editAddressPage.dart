import 'dart:convert';

import 'package:city_pickers/city_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
 class EditAddressPage extends StatefulWidget {
   String address_id;
   EditAddressPage({this.address_id});
   @override
   _EditAddressPageState createState() => _EditAddressPageState();
 }
 
 class _EditAddressPageState extends State<EditAddressPage> with TickerProviderStateMixin {

   TextEditingController receive_name_controller = new TextEditingController();
   TextEditingController receive_phone_controller = new TextEditingController();
   TextEditingController address_controller = new TextEditingController();
   TextEditingController postal_code_controller = new TextEditingController();

   String CRI_CODE = '';
   String CRI_NAME = '';
   String area = '';
   String old_area = '';
   bool check = false;
   bool _showLoading = false;
   Map addressInfo;


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
    var formData = {"id": widget.address_id};
    request('address_detail_api', formData: formData).then((val) {
      var data = json.decode(val.toString());
      print(data);
      if (data['code'] == 200) {
        setState(() {
          addressInfo = data['data'];
          receive_phone_controller.text = data['data']['receive_phone'].toString();
          receive_name_controller.text = data['data']['receive_name'].toString();
          address_controller.text = data['data']['address'].toString();
          postal_code_controller.text = data['data']['postal_code'].toString();
          CRI_CODE = data['data']['CRI_CODE'].toString();
          CRI_NAME = data['data']['CRI_NAME'].toString();
          old_area = data['data']['show_address'];
          area = data['data']['show_address'];
          if(data['data']['is_default'] == 1){
            check = true;
          }
          _showLoading = false;
        });
      }
    });
  }

   void _edit_Address() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     int is_check = 2;
     if(check){
       is_check = 1;
     }
     String address_Info = address_controller.text;
     if(area != old_area){
       address_Info = area+address_controller.text;
     }
     var userid = prefs.getString('userId').toString();
     var formData = {"id": widget.address_id,"uid": userid,"receive_name": receive_name_controller.text,"receive_phone": receive_phone_controller.text,"CRI_CODE": CRI_CODE,"CRI_NAME": CRI_NAME,"address": address_Info,"postal_code": postal_code_controller.text,"is_default": is_check};
     request('address_edit_api', formData: formData).then((val) {
       var data = json.decode(val.toString());
       print(data);
       if (data['code'] == 200) {
         Navigator.of(context).pop();
       }
       toast(data['message']);
     });
   }

   void _deleted_Address() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     var formData = {"id": widget.address_id};
     request('address_deleted_api', formData: formData).then((val) {
       var data = json.decode(val.toString());
       print(data);
       if (data['code'] == 200) {
         Navigator.of(context).pop();
       }
       toast(data['message']);
     });
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
         appBar: AppBar(
           title: Text('编辑收货地址'),
           centerTitle: true,
         ),
         body:_showLoading ?
         Center(
           child: SpinKitThreeBounce(
             color: Colors.lightGreen,
             size: 50.0,
             controller: AnimationController(
                 vsync: this,
                 duration: const Duration(milliseconds: 1200)),
           ),
         ) : Container(
           padding: EdgeInsets.all(10),
           child: ListView(
             children: <Widget>[
               Container(
                 child: ListTile(
                   leading: Icon(FontAwesomeIcons.userAlt),
                   title: TextField(
                     controller: receive_name_controller,
                     style: TextStyle(
                         fontSize: ScreenUtil().setSp(28)
                     ),
                     decoration: InputDecoration(
                       hintText: '收货人姓名',
                       border: InputBorder.none,
                     ),
                   ),
                 ),
               ),
               Container(
                 child: ListTile(
                   leading: Icon(FontAwesomeIcons.mobile),
                   title: TextField(
                     controller: receive_phone_controller,
                     keyboardType: TextInputType.number,
                     style: TextStyle(
                         fontSize: ScreenUtil().setSp(28)
                     ),
                     decoration: InputDecoration(
                       hintText: '收货人手机号',
                       border: InputBorder.none,
                     ),
                   ),
                 ),
               ),
               Container(
                 child: ListTile(
                   leading: Icon(FontAwesomeIcons.mapMarkerAlt),
                   title: Text(area==''?'选择省/市/区':area,style: TextStyle(
                     color: Color(0x8a000000)
                   ),),
                   onTap: () async {
                     Result result = await CityPickers.showCityPicker(
                         context: context,
                         cancelWidget:
                         Text('取消', style: TextStyle(color: Colors.black54)),
                         confirmWidget:
                         Text("确定", style: TextStyle(color: Colors.blue)));
                     setState(() {
                       if(result!=null){
                         address_controller.clear();
                        this.area = "${result.provinceName}${result.cityName}${result.areaName}";
                        this.CRI_CODE = result.areaId;
                        this.CRI_NAME = result.areaName;
                       }
                     });
                   },
                 ),
               ),
               Container(
                 child: ListTile(
                   leading: Icon(FontAwesomeIcons.locationArrow),
                   title: TextField(
                     controller: address_controller,
                     style: TextStyle(
                         fontSize: ScreenUtil().setSp(28)
                     ),
                     decoration: InputDecoration(
                       hintText: '街道门牌、楼层房间号等信息',
                       border: InputBorder.none,
                     ),
                   ),
                 ),
               ),
               Container(
                 child: ListTile(
                   leading: Icon(FontAwesomeIcons.usps),
                   title: TextField(
                     controller: postal_code_controller,
                     keyboardType: TextInputType.number,
                     style: TextStyle(
                         fontSize: ScreenUtil().setSp(28)
                     ),
                     decoration: InputDecoration(
                       hintText: '邮政编码',
                       border: InputBorder.none,
                     ),
                   ),
                 ),
               ),
               Container(
                 child: ListTile(
                   title:Text('设为默认收货地址',style: TextStyle(
                       fontSize: ScreenUtil().setSp(28)
                   ),),
                   trailing: Switch(
                     value: this.check,
                     activeColor: Colors.blue,
                     onChanged: (bool val) {
                       this.setState(() {
                         this.check = !this.check;
                       });
                     },
                   ),
                 ),
               ),
               Container(
                 margin: EdgeInsets.only(top: 30),
                 height: ScreenUtil().setHeight(70),
                 padding: EdgeInsets.only(left:30,right: 30),
                 child: MaterialButton(
                   color: Colors.red,
                   onPressed: (){
                     _edit_Address();
                   },
                   child: Text('保存',style: TextStyle(
                     fontSize: ScreenUtil().setSp(28),
                     color: Colors.white,
                   ),),
                 ),
               ),
               Container(
                 margin: EdgeInsets.only(top: 30),
                 height: ScreenUtil().setHeight(70),
                 padding: EdgeInsets.only(left:30,right: 30),
                 child: MaterialButton(
                   color: Colors.white,
                   onPressed: (){

                     showDialog<Null>(
                         context: context,
                         barrierDismissible: false,
                         builder: (BuildContext context) {
                       return new AlertDialog(
                         title: new Text('是否确认删除?'),
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
                               Navigator.of(context).pop();
                               _deleted_Address();
                             },
                           ),
                         ],
                       );
                     });
                   },
                   child: Text('删除',style: TextStyle(
                     fontSize: ScreenUtil().setSp(28),
                     color: Colors.black,
                   ),),
                 ),
               ),
             ],
           ),
         )
     );
   }
 }
 