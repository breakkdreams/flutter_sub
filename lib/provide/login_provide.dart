import 'package:flutter/material.dart';

//ChangeNotifier的混入是不用管理听众
class LoginProvide with ChangeNotifier {
  String user_id = '';
  setUserId(String userId){
    user_id = userId;
    notifyListeners();
  }
}
