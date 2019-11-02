import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'provide/login_provide.dart';
import 'package:provide/provide.dart';
import './routers/routes.dart';
import './routers/application.dart';
import 'pages/loginPage.dart';

void main(){
  var loginProvide=LoginProvide();
  var providers = Providers();

  providers
    ..provide(Provider<LoginProvide>.value(loginProvide));

  runApp(ProviderNode(child:MyApp(),providers:providers));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //-------------------主要代码start
    final router = Router(); //路由初始化
    Routes.configureRoutes(router);
    Application.router = router;
    //-------------------主要代码end

    return MaterialApp(
      title: 'Flutter Demo',
      //----------------主要代码start
      onGenerateRoute: Application.router.generator, //路由静态化
      //----------------主要代码end
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}