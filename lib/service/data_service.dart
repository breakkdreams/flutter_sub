import 'dart:convert';

import "package:dio/dio.dart";
import 'package:flutter_sub/utils/secret.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import '../config/service_url.dart';

Future request(url,{formData})async{
  try{
    Response response;
    Dio dio = new Dio();
    dio.options.contentType=ContentType.parse("application/x-www-form-urlencoded");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String secret_open = prefs.getString('secret_open');//1开 0关
    if(secret_open == '1') { //要加密
      var lock_data = lock(formData);
      await lock_data.then((params) async {
        formData = {'data':params};
        if(formData==null){
          response = await dio.post(servicePath[url]);
        }else{
          response = await dio.post(servicePath[url],data:formData);
        }
        if(response.statusCode==200){
          var data = json.decode(response.data.toString());
          var unlock = delock(data['data']);
          await unlock.then((unlock_data) async {
            data['data'] = json.decode(unlock_data.toString());
            print("+++++++++");
            print(data);
            print("+++++++++");
            return await data;
          });
        }else{
          throw Exception('后端接口出现异常，请检测代码和服务器情况.........');
        }
      });
    }else{
      if(formData==null){
        response = await dio.post(servicePath[url]);
      }else{
        response = await dio.post(servicePath[url],data:formData);
      }
      if(response.statusCode==200){
        return response.data;
      }else{
        throw Exception('后端接口出现异常，请检测代码和服务器情况.........');
      }
    }
  }catch(e){
    return print('ERROR:======>${e}');
  }
}

Future http_get(url,{formData})async{
  try{
    Response response;
    Dio dio = new Dio();
    dio.options.contentType=ContentType.parse("application/x-www-form-urlencoded");
    if(formData==null){
      response = await dio.get(servicePath[url]);
    }else{
      response = await dio.get(servicePath[url],queryParameters:formData);
    }
    if(response.statusCode==200){
      return response.data;
    }else{
      throw Exception('后端接口出现异常，请检测代码和服务器情况.........');
    }
  }catch(e){
    return print('ERROR:======>${e}');
  }

}