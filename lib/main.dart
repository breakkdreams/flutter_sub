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
    final router = Router();
    Routes.configureRoutes(router);
    Application.router = router;
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: Application.router.generator,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}