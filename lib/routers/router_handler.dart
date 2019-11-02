import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/pages/addAddressPage.dart';
import 'package:flutter_sub/pages/address_page.dart';
import 'package:flutter_sub/pages/editAddressPage.dart';
import 'package:flutter_sub/pages/goodsDetailPage.dart';
import 'package:flutter_sub/pages/goodsListPage.dart';
import 'package:flutter_sub/pages/messageDetailPage.dart';
import 'package:flutter_sub/pages/messageListPage.dart';
import 'package:flutter_sub/pages/orderListPage.dart';
import 'package:flutter_sub/pages/settlementPage.dart';
import '../pages/alipayBandPage.dart';
import '../pages/bankBandPage.dart';
import '../pages/forgetMobilePage.dart';
import '../pages/forgetPayNextPasswordPage.dart';
import '../pages/forgetPayPasswordPage.dart';
import '../pages/myAccountPage.dart';
import '../pages/myWalletPage.dart';
import '../pages/payPasswordPage.dart';
import '../pages/setNewMobilePage.dart';
import '../pages/wechatBandPage.dart';
import '../pages/index_page.dart';
import '../pages/loginPage.dart';
import '../pages/editPersonalPage.dart';
import '../pages/safetyCenterPage.dart';
import '../pages/setPasswordPage.dart';
import '../pages/forgetPasswordPage.dart';
import '../pages/forgetNextPasswordPage.dart';

Handler homeHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
//      String goodsId = params['id'].first;
      return Index(cindex:3);
    }
);

Handler loginHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return LoginPage();
    }
);

Handler editPersonalHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return EditPersonalPage();
    }
);

Handler safetyCenterHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return SafetyCenterPage();
    }
);

Handler setPasswordHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return SetPasswordPage();
    }
);

Handler forgetPasswordHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return ForgetPasswordPage();
    }
);

Handler payPasswordHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return PayPasswordPage();
    }
);

Handler forgetNextPasswordHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      String mobile = params['mobile'].first;
      String mobile_code = params['mobile_code'].first;
      return ForgetNextPasswordPage(mobile:mobile,mobile_code:mobile_code);
    }
);

Handler forgetPayPasswordHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return ForgetPayPasswordPage();
    }
);

Handler forgetPayNextPasswordHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      String mobile = params['mobile'].first;
      String mobile_code = params['mobile_code'].first;
      return ForgetPayNextPasswordPage(mobile:mobile,mobile_code:mobile_code);
    }
);

Handler forgetMobileHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return ForgetMobilePage();
    }
);

Handler setNewMobileHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      String mobile = params['mobile'].first;
      String mobile_code = params['mobile_code'].first;
      return SetNewMobilePage(old_mobile:mobile,old_mobile_code:mobile_code);
    }
);

Handler myWalletHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return MyWalletPage();
    }
);

Handler myAccountHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return MyAccountPage();
    }
);

Handler bandWeChatHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      String wechat_id = params['id'].first;
      return WechatBandPage(wechat_id:wechat_id);
    }
);

Handler aliPayHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      String alipay_id = params['id'].first;
      return AlipayBandPage(alipay_id:alipay_id);
    }
);

Handler bankBandHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return BankBandPage();
    }
);

Handler addressListHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      String need_return = params['need_return'].first;
      return AddressListPage(need_return:need_return);
    }
);

Handler addAaddressHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return AddAddressPage();
    }
);

Handler editAaddressHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      String address_id = params['id'].first;
      return EditAddressPage(address_id:address_id);
    }
);

Handler messageListHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      return MessageListPage();
    }
);

Handler messageDetailHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      String message_id = params['id'].first;
      return MessageDetailPage(message_id:message_id);
    }
);
Handler goodsListHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      String catid = '';
      var sercon = '';
      if(params['catid'] != null){
        catid = params['catid'].first;
      }
      if(params['sercon'] != null){
        sercon = params['sercon'].first;
      }
      return GoodsListPage(catid:catid,sercon:sercon);
    }
);

Handler goodsDetailHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      String goods_id = params['id'].first;
      return GoodsDetailPage(goods_id:goods_id);
    }
);

Handler orderListHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
//      String goods_id = params['id'].first;
      return OrderListPage();
    }
);