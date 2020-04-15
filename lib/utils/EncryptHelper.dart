import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

final parser = RSAKeyParser();

abstract class EncryptHelper {

  static Future<String>  encodeLong(Map para) async{
    String publicKeyString = await rootBundle.loadString('assets/rsa/public.pem');
    RSAPublicKey publicKey = parser.parse(publicKeyString);
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    final jsonStr = jsonEncode(para);
    List<int> sourceByts = utf8.encode(jsonStr);
    int inputLen = sourceByts.length;
    int maxLen = 117;
    List<int> totalByts = List();
    for (var i = 0; i < inputLen; i += maxLen) {
      int endLen = inputLen - i;
      List<int> item;
      if (endLen > maxLen) {
        item = sourceByts.sublist(i, i+maxLen);
      }else{
        item = sourceByts.sublist(i, i+endLen);
      }
      totalByts.addAll(encrypter.encryptBytes(item).bytes);
    }
    String en = base64.encode(totalByts);
    return en;
  }
}