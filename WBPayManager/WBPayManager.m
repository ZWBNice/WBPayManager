//
//  WBPayManager.m
//  iBreathDoctor_New
//
//  Created by ifly on 2019/1/11.
//  Copyright © 2019 zwb. All rights reserved.
//

#import "WBPayManager.h"
#define WXPayid @"wxcf90f5318e827bfe"
#define APPSCHEME @"smartbottlecapnew"

@interface WBPayManager ()<WXApiDelegate>

@property (nonatomic, copy) void(^PaySuccess)(PayCode code);
@property (nonatomic, copy) void(^PayError)(PayCode code , NSString *errorText);

@end

@implementation WBPayManager

static id _instance;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[WBPayManager alloc] init];
    });
    
    return _instance;
}


///回调处理
- (BOOL) handleOpenURL:(NSURL *)url
{
    if ([url.host isEqualToString:@"safepay"])
    {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            DELog(@"result = %@",resultDic);
            
            NSInteger resultCode = [resultDic[@"resultStatus"] integerValue];
            switch (resultCode) {
                case 9000:     //支付成功
                    self.PaySuccess(ALIPAYSUCESS);
                    break;
                    
                case 6001:     //支付取消
                    self.PaySuccess(ALIPAYCANCEL);
                    break;
                    
                default:        //支付失败
                    self.PaySuccess(ALIPAYERROR);
                    break;
            }
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            DELog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            DELog(@"授权结果 authCode = %@", authCode?:@"");
        }];
        return YES;
    } //([url.host isEqualToString:@"pay"]) //微信支付
    return [WXApi handleOpenURL:url delegate:self];
}

///微信支付

- (void)wxPayWithPayReq:(BaseReq *)req success:(void (^)(PayCode))successBlock failure:(void (^)(PayCode, NSString * _Nonnull))failBlock{
    self.PaySuccess = successBlock;
    self.PayError = failBlock;
    
    
    [WXApi registerApp:WXPayid];
    
    if(![WXApi isWXAppInstalled]) {
        failBlock(WXERROR_NOTINSTALL,@"未安装微信");
        return ;
    }
    if (![WXApi isWXAppSupportApi]) {
        failBlock(WXERROR_UNSUPPORT,@"微信不支持");
        return ;
    }
    
    [WXApi sendReq:req];

}

#pragma mark - 微信回调
// 微信终端返回给第三方的关于支付结果的结构体
- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]])
    {
        switch (resp.errCode) {
            case WXSuccess:
                self.PaySuccess(WXSUCESS);
                break;
                
            case WXErrCodeUserCancel:   //用户点击取消并返回
                self.PayError(WXSCANCEL,@"取消支付");
                break;
                
            default:        //剩余都是支付失败
                self.PayError(WXERROR,@"支付失败");
                break;
        }
    }
}

#pragma mark 支付宝支付
- (void)aliPayWithPayParam:(NSString *)pay_param success:(void (^)(PayCode))successBlock failure:(void (^)(PayCode, NSString * _Nonnull))failBlock{
    self.PaySuccess = successBlock;
    self.PayError = failBlock;
    NSString * appScheme =  APPSCHEME;
    [[AlipaySDK defaultService] payOrder:pay_param fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        DELog(@"----- %@",resultDic);
        NSInteger resultCode = [resultDic[@"resultStatus"] integerValue];
        switch (resultCode) {
            case 9000:     //支付成功
                successBlock(ALIPAYSUCESS);
                break;
                
            case 6001:     //支付取消
                failBlock(ALIPAYCANCEL,@"取消支付");
                break;
                
            default:        //支付失败
                failBlock(ALIPAYERROR,@"支付失败");
                break;
        }
    }];
}



@end
