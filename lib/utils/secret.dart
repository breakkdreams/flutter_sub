import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:rsa_plugin/rsa_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_rsa/simple_rsa.dart';

Future<String> lock(param) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var rsa_public_key = '-----BEGIN PUBLIC KEY-----\n' +
      'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDPTwOT15xFv3Klf/zAO7qP/1DC\n' +
      'UNns5bzh3sDltxQM/B6fpIVlHnrzRiAyAwWSXh21ILXBsJATVU+wy+XbbP+yS2tb\n' +
      '/JzsdpHJeWT98TVB/hRaJY916dT9jMwo8QUxCOuXudx8vHJOf38XeKgLyPYGkq5F\n' +
      'fCYySAohIYv5TxC2ywIDAQAB\n' +
      '-----END PUBLIC KEY-----';
  var content = utf8.encode(rsa_public_key);
  var digest = base64Encode(content);
  final parser = RSAKeyParser();
  var timestamp = DateTime.now().millisecondsSinceEpoch;
  String alphabet =
      'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890';
  int strlenght = 30;
  String noncestr = '';
  for (var i = 0; i < strlenght; i++) {
    noncestr = noncestr + alphabet[Random().nextInt(alphabet.length)];
  }
  String appid = '123456';
  var jsapi_ticket = prefs.get('jsapi_ticket');
  var paramString = '';
  var st = new SplayTreeMap<String, Object>();
  var data = {
    "appid": appid,
    "timestamp": timestamp,
    "noncestr": noncestr,
    "jsapi_ticket": jsapi_ticket,
  };
  st.addAll(data);
  st.addAll(param);
  st.forEach((key, value) {
    paramString += key + '=' + value.toString() + '&';
  });
  paramString = paramString.substring(0, paramString.length - 1);
  var signature =
      md5.convert(utf8.encode(paramString)).toString().toUpperCase();
  var mm = paramString + '&signature=' + signature;
  var encryptedText =
      await encryptString(mm, utf8.decode(base64.decode(digest)));
  return encryptedText;
}

Future<String> delock(param) async {
  var encryptedText = RsaPlugin.platformVersion(param);
  return encryptedText;
}
