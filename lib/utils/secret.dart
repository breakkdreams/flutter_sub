
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_rsa/simple_rsa.dart';

///加密
 Future<String> lock(param) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var rsa_public_key= '-----BEGIN PUBLIC KEY-----\n' +
      'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDPTwOT15xFv3Klf/zAO7qP/1DC\n' +
      'UNns5bzh3sDltxQM/B6fpIVlHnrzRiAyAwWSXh21ILXBsJATVU+wy+XbbP+yS2tb\n' +
      '/JzsdpHJeWT98TVB/hRaJY916dT9jMwo8QUxCOuXudx8vHJOf38XeKgLyPYGkq5F\n' +
      'fCYySAohIYv5TxC2ywIDAQAB\n' +
      '-----END PUBLIC KEY-----';
  var content = utf8.encode(rsa_public_key);
  var digest = base64Encode(content);

  final parser = RSAKeyParser();

  //获取当前时间时间戳
  var timestamp = DateTime.now().millisecondsSinceEpoch;
  //生成随机数
  String alphabet = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890';
  int strlenght = 30; /// 生成的字符串固定长度
  String noncestr = '';
  for (var i = 0; i < strlenght; i++) {
    noncestr = noncestr + alphabet[Random().nextInt(alphabet.length)];
  }

  /**
   * 生成签名
   * @param  {[type]} data [json数组]
   * @return {[type]}      [description]
   */
  String appid = '123456';
  var jsapi_ticket = prefs.get('jsapi_ticket');
  var paramString = '';
  //排序
  var st = new SplayTreeMap<String, Object>();
  var data = { "appid": appid, "timestamp": timestamp, "noncestr": noncestr, "jsapi_ticket": jsapi_ticket,};
  st.addAll(data);
  st.addAll(param);

  st.forEach((key, value) {
    paramString += key + '=' + value.toString() + '&';
  });
  paramString = paramString.substring(0, paramString.length - 1);
  var signature = md5.convert(utf8.encode(paramString)).toString().toUpperCase();
  var mm = paramString + '&signature=' + signature;
  var encryptedText = await encryptString(mm, utf8.decode(base64.decode(digest)));
  return encryptedText;
}

///解密
Future<String> delock(param) async {

 var rsa_private_key = '-----BEGIN RSA PRIVATE KEY-----\n' +
     'MIICWwIBAAKBgQCU5NCXrdQcVpZzB30bgKu7yaxPVGqJ7gnXqBXKR2JuOJvWQi3i\n' +
     'yiEfRTFNw0b3rHlUuOsR11JCoBZ+Ygv6+tv0FkRwi8lzyVLSgrxY5iKtc+/qOU3g\n' +
     'zq1Cd80ZmkeiwSLH+mSuRCmA8wuU73nG+wJcxW4vL/MTPmvDYnpto+tbMQIDAQAB\n' +
     'AoGAAyQV7q/Ao6IgzMeMr5FdP4ilWPpvS750e3iweStzv/X/QN6vqodbNATr28ZB\n' +
     'yx1x/G+22N2d8zItT0y4EEyNgZZMoxhDHTJWHZJzqQsDCvpLsgJxto2zQ4KKCl4l\n' +
     'dGvsLF8gHbeULKDLgEwPhD/6KwcVWA89nP/S4y9/ji3bec0CQQDfkcdsv1Y+7dTc\n' +
     '0/rPfyans3+yLG1lPzzFGyJAcz5eUsfgItXmJEzPgib0ePgOk5e/JTimzqXkQlaa\n' +
     '+BwtgfdFAkEAqn33T4GzL+pZrVa3aKx1aukQKSQ8uR/CCdu1o+vt/kgu/vWwpWog\n' +
     '7MH16HyzQkG7CsC5Ul80CHf6EUImTyPM/QJAOZxfP26u0tiGmcEmSIIDfAONTGSW\n' +
     'bBi3mDM9yE3qLHQ4fVF8vSltgauQTj897MOrvt3gk1t89C0EFDsLR87N4QJAfmUI\n' +
     'lc7n0twAQ7uIGXfRTMMgEgAlbHEY30odLTtZoyxMewQWQ2ucoSlib0sTcklcqyoZ\n' +
     'ufGOl8CqiWTrFbzK2QJAOgDhwA013TF4P9qaLNscJ1O5gV+rDUR/g3CGaYl4lKVI\n' +
     '99rdyEWxmpch9/HnAGAIlDOTsIM78fA/hFZHpoULrQ==\n' +
     '-----END RSA PRIVATE KEY-----';

 var content = utf8.encode(rsa_private_key);
 var digest = base64Encode(content);
 // 解密
 var encryptedText = await decryptString(param, utf8.decode(base64.decode(digest)));
 return encryptedText;
}


///加密解密方法
//void test_method() async {
// SharedPreferences prefs = await SharedPreferences.getInstance();
// String secret_open = prefs.getString('secret_open');//1开 0关
// ///参数
// var userid = prefs.getString('userId').toString();
// var formData = {"uid": userid};
// if(secret_open == '1'){
//  var lock_data = lock(formData);
//  lock_data.then((params){
//   request('testApi', formData: {'data':params}).then((val) async {
//    var data = json.decode(val.toString());
//    var unlock = delock(data['data']);
//    unlock.then((unlock_data){
//     var result = json.decode(unlock_data);
//    });
//   });
//  });
// }else{
//  request('testApi', formData: {'data':formData}).then((val) async {
//   var data = json.decode(val.toString());
//  });
// }
//}