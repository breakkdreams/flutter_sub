import 'dart:convert';

import 'package:city_pickers/city_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sub/service/data_service.dart';
import 'package:flutter_sub/utils/secret.dart';
import 'package:flutter_sub/utils/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
 class AddAddressPage extends StatefulWidget {
   @override
   _AddAddressPageState createState() => _AddAddressPageState();
 }
 
 class _AddAddressPageState extends State<AddAddressPage> {

   TextEditingController receive_name_controller = new TextEditingController();
   TextEditingController receive_phone_controller = new TextEditingController();
   TextEditingController address_controller = new TextEditingController();
   TextEditingController postal_code_controller = new TextEditingController();

   String CRI_CODE = '';
   String CRI_NAME = '';
   String area = '';
   bool check = false;

   void _add_Address() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     ///参数
     int is_check = 2;
     if(check){
       is_check = 1;
     }
     var userid = prefs.getString('userId').toString();
     var formData = {"uid": userid,"receive_name": receive_name_controller.text,"receive_phone": receive_phone_controller.text,"CRI_CODE": CRI_CODE,"CRI_NAME": CRI_NAME,"address": area+address_controller.text,"postal_code": postal_code_controller.text,"is_default": is_check};
     request('address_add_api', formData: formData).then((val) {
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
           title: Text('增加收货地址'),
           centerTitle: true,
         ),
         body:
         Container(
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
                     print(result);
                     setState(() {
                       if(result!=null){
                        this.area = "${result.provinceName}${result.cityName}${result.areaName}";
                        this.CRI_CODE = result.areaId;
                        this.CRI_NAME = result.areaName;
//                        this.city = result.cityName;
//                        this.distrct = result.areaName;
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
                     activeColor: Colors.blue,     // 激活时原点颜色
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
                     _add_Address();
                   },
                   child: Text('保存',style: TextStyle(
                     fontSize: ScreenUtil().setSp(28),
                     color: Colors.white,
                   ),),
                 ),
               ),
             ],
           ),
         )
     );
   }
 }
 