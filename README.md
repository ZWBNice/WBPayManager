# WBPayManager
Alipay and WXPay Manager
Tips: 支付宝 需要 先添加好URL Scheme
infoplist 中 添加
<key>LSApplicationQueriesSchemes</key>
 <array>
    <!-- 微信 URL Scheme 白名单-->
    <string>wechat</string>
    <string>weixin</string>
    <!-- 支付宝  URL Scheme 白名单-->
    <string>alipay</string>
    <string>alipayshare</string>
</array>
1. appdelegate 中引入 头文件 #import <WBPayManager.h>
2.  
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[WBPayManager shared] confingAppScheme:@"AppScheme"];
    [[WBPayManager shared] configWXPayIdWithWXid:@"wxKey"];
    return YES;
}

3. appdelegate 中添加
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options{
    return [[WBPayManager shared] handleOpenURL:url];
}


4.调用

    [[WBPayManager shared] aliPayWithPayParam:@"" success:^(PayCode code) {
        
    } failure:^(PayCode code, NSString * _Nonnull errorText) {
        
    }];
    PayReq* req             = [[PayReq alloc] init];
    req.partnerId           = @"partnerId";
    req.prepayId            = @"prepayid";
    req.nonceStr            = @"noncestr";
    req.timeStamp           = @"timestamp".intValue;
    req.package             = @"Sign=WXPay";
    req.sign                = @"sign";

    [[WBPayManager shared] wxPayWithPayReq:req success:^(PayCode code) {
        
    } failure:^(PayCode code, NSString * _Nonnull errorText) {
        
    }];
