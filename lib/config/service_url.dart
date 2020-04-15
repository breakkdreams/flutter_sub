const baseUrl = 'http://js3.300c.cn/shop/public/';


const servicePath={
  'sendMsg': baseUrl+'plugin/message/api_index/smsCode',//注册验证码
  'agreementPageContent': baseUrl+'plugin/member/api_index/agreement',//注册协议
  'registerPageContent': baseUrl+'/plugin/member/api_index/mobileRegister',//注册
  'loginPageContent': baseUrl+'/plugin/member/api_index/accountLogin',//登录
  'userInfoPageContent': baseUrl+'/plugin/member/api_index/personalData',//用户信息
  'grPageContent': baseUrl+'/plugin/member/api_index/gr_index',//个人中心---浏览足迹/商品收藏
  'myToolsPageContent': baseUrl+'/plugin/member/apiIndex/toolsMenu&type=1',//个人中心---我的工具
  'uploadHeadImgContent': baseUrl+'/plugin/member/api_index/single_uploadFile',//头像修改
  'updateUserPageContent': baseUrl+'/plugin/member/api_index/editPersonal',//修改用户信息
  'accessToken_api': baseUrl+'/api/api_common/accessToken',//获取accessToken
  'jsapi_ticket_api': baseUrl+'/api/api_common/getToken',//获取jsapi_ticket
  'edit_password_api': baseUrl+'/plugin/member/api_index/editPassword',//设置登录密码
  'pay_password_api': baseUrl+'/plugin/member/api_index/editPayPassword',//设置支付密码
  'forget_password_api': baseUrl+'/plugin/member/api_index/forgetPassword',//忘记密码
  'forget_pay_password_api': baseUrl+'/plugin/member/api_index/editNoPayPassword',//忘记支付密码
  'forget_mobile_api': baseUrl+'/plugin/member/api_index/editMobile',//忘记手机
  'my_account_api': baseUrl+'/plugin/fund/api_index/index',//我的账户
  'edit_account_api': baseUrl+'/plugin/fund/api_index/updateamount',//修改绑定
  'add_account_api': baseUrl+'/plugin/fund/api_index/addaccount',//添加绑定
  'set_default_bank_api': baseUrl+'/plugin/fund/api_index/defaultaccount',//设置默认银行卡
  'deleted_account_api': baseUrl+'/plugin/fund/api_index/delaccount',//删除银行卡
  'address_list_api': baseUrl+'/plugin/member_address/apiIndex/getAddressList',//获取收货地址列表
  'address_add_api': baseUrl+'/plugin/member_address/apiIndex/addAdress',//新增地址
  'address_detail_api': baseUrl+'/plugin/member_address/apiIndex/getAddressInfo',//获取地址详情
  'address_edit_api': baseUrl+'/plugin/member_address/apiIndex/editAddress',//修改地址
  'address_deleted_api': baseUrl+'/plugin/member_address/apiIndex/deleteAddress',//删除地址
  'message_list_api': baseUrl+'/plugin/message/api_index/message',//消息中心
  'message_detail_api': baseUrl+'/plugin/message/api_index/messageDetail',//消息详情
  'category_list_api': baseUrl+'/plugin/goods/api_index/getgoodscat',//分类
  'goods_list_api': baseUrl+'/plugin/goods/api_index/goodslist',//商品列表
  'goods_info_api': baseUrl+'/plugin/goods/api_index/goodsinfo',//商品详情
  'footprint_api': baseUrl+'/plugin/member/api_index/footprintOperation',//添加足迹
  'goods_spec_api': baseUrl+'/plugin/goods/api_index/getspec',//获取商品配置
  'add_cart_api': baseUrl+'/plugin/goods/api_index/addcarts',//加入购物车
  'buy_now_api': baseUrl+'/plugin/goods/api_index/buynowsettlement',//立即购买
  'default_address_api': baseUrl+'/plugin/member_address/apiIndex/getDefaultAddress',//获取默认地址
  'make_order_api': baseUrl+'/plugin/order/api_index/sureMakeOrder',//生成订单
  'add_payment_api': baseUrl+'/plugin/fund/api_index/addpayment',//添加账单
  'balance_api': baseUrl+'/plugin/fund/api_index/balance',//订单支付
  'home_banner_api': baseUrl+'/plugin/home_configuration/api_index/getCarouselInfo',//首页轮播
  'home_category_api': baseUrl+'/plugin/home_configuration/api_index/getTypeInfo',//首页分类
  'home_goods_api': baseUrl+'/plugin/goods/api_index/goodslist',//首页商品
  'home_recommend_api': baseUrl+'/plugin/home_configuration/api_index/getRecomInfo',//首页推荐
  'search_history_api': baseUrl+'/plugin/goods/api_index/goods_sh',//搜索历史记录
  'cart_list_api': baseUrl+'/plugin/goods/api_index/getcarts',//获取购物车数据
  'cart_opera_api': baseUrl+'/plugin/goods/api_index/operacars',//购物车数量加减
  'cart_deleted_api': baseUrl+'/plugin/goods/api_index/delcarts',//购物车删除
  'cart_settlement_api': baseUrl+'/plugin/goods/api_index/settlement',//购物车结算
  'order_list_api': baseUrl+'/plugin/order/api_index/allOrder',//订单列表




  'testApi': baseUrl+'/plugin/member/api_index/index',//测试

};