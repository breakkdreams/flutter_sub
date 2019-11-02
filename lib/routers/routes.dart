import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import './router_handler.dart';

class Routes { //配置类
  static String root = '/'; //根目录
  static String loginPage = '/loginPage'; //登录
  static String homePage = '/home'; //注册
  static String editPersonalPage = '/editPersonal'; //编辑个人资料
  static String safetyCenterPage = '/safetyCenter'; //安全中心
  static String setPasswordPage = '/setPassword'; //设置登录密码
  static String forgetPasswordPage = '/forgetPassword'; //忘记密码
  static String forgetNextPasswordPage = '/forgetNextPassword'; //忘记密码二
  static String payPasswordPage = '/payPassword'; //设置支付密码
  static String forgetPayPasswordPage = '/forgetPayPassword'; //忘记支付密码
  static String forgetPayNextPasswordPage = '/forgePaytNextPassword'; //忘记密码二
  static String forgetMobilePage = '/forgeMobile'; //修改手机号
  static String setNewMobilePage = '/setNewMobile'; //修改手机号二
  static String myWalletPage = '/myWallet'; //我的钱包
  static String myAccountPage = '/myAccount'; //我的账户
  static String bandWeChatPage = '/bandWechat'; //绑定微信
  static String aliPayBandPage = '/alipayBand'; //绑定支付宝
  static String bankBandPage = '/bankBandBand'; //绑定银行卡
  static String addressListPage = '/addressList'; //收货地址列表
  static String addAddressPage = '/addAddress'; //添加收货地址
  static String editAddressPage = '/editAddress'; //编辑收货地址
  static String messageListPage = '/messageList'; //消息中心
  static String messageDetailPage = '/messageDetail'; //消息详情
  static String goodsListPage = '/goodsList'; //商品列表
  static String goodsDetailPage = '/goodsDetail'; //商品详情
  static String orderListPage = '/orderList'; //订单列表


  //静态方法
  static void configureRoutes(Router router){//路由配置
    //找不到路由
    router.notFoundHandler = new Handler(
        // ignore: missing_return
        handlerFunc: (BuildContext context,Map<String,List<String>> params){
          print('ERROR====>ROUTE WAS NOT FONUND!!!');
        }
    );
    //整体配置
    router.define(loginPage, handler: loginHandler);
    router.define(homePage, handler: homeHandler);
    router.define(editPersonalPage, handler: editPersonalHandler);
    router.define(safetyCenterPage, handler: safetyCenterHandler);
    router.define(setPasswordPage, handler: setPasswordHandler);
    router.define(forgetPasswordPage, handler: forgetPasswordHandler);
    router.define(forgetNextPasswordPage, handler: forgetNextPasswordHandler);
    router.define(payPasswordPage, handler: payPasswordHandler);
    router.define(forgetPayPasswordPage, handler: forgetPayPasswordHandler);
    router.define(forgetPayNextPasswordPage, handler: forgetPayNextPasswordHandler);
    router.define(forgetMobilePage, handler: forgetMobileHandler);
    router.define(setNewMobilePage, handler: setNewMobileHandler);
    router.define(myWalletPage, handler: myWalletHandler);
    router.define(myAccountPage, handler: myAccountHandler);
    router.define(bandWeChatPage, handler: bandWeChatHandler);
    router.define(aliPayBandPage, handler: aliPayHandler);
    router.define(bankBandPage, handler: bankBandHandler);
    router.define(addressListPage, handler: addressListHandler);
    router.define(addAddressPage, handler: addAaddressHandler);
    router.define(editAddressPage, handler: editAaddressHandler);
    router.define(messageListPage, handler: messageListHandler);
    router.define(messageDetailPage, handler: messageDetailHandler);
    router.define(goodsListPage, handler: goodsListHandler);
    router.define(goodsDetailPage, handler: goodsDetailHandler);
    router.define(orderListPage, handler: orderListHandler);

  }

}