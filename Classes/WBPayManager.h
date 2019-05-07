//
//  WBPayManager.h
//  iBreathDoctor_New
//
//  Created by ifly on 2019/1/11.
//  Copyright © 2019 zwb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "AlipaySDK.h"


typedef NS_ENUM(NSInteger, PayCode) {
    
    WXSUCESS            = 1001,   /**< 成功    */
    WXERROR             = 1002,   /**< 失败    */
    WXSCANCEL           = 1003,   /**< 取消    */
    WXERROR_NOTINSTALL  = 1004,   /**< 未安装微信   */
    WXERROR_UNSUPPORT   = 1005,   /**< 微信不支持    */
    WXERROR_PARAM       = 1006,   /**< 支付参数解析错误   */
    
    ALIPAYSUCESS        = 1101,   /**< 支付宝支付成功 */
    ALIPAYERROR         = 1102,   /**< 支付宝支付错误 */
    ALIPAYCANCEL        = 1103,   /**< 支付宝支付取消 */
};


NS_ASSUME_NONNULL_BEGIN

@interface WBPayManager : NSObject

/**
 *  获取单例
 */
+ (instancetype)shared;

/**
 *  发起微信支付请求
 *
 *  @param req    支付参数
 *  @param successBlock 成功
 *  @param failBlock    失败
 */
- (void)wxPayWithPayReq:(BaseReq *)req
                  success:(void (^)(PayCode code))successBlock
                  failure:(void (^)(PayCode code ,NSString *errorText))failBlock;

/**
 *  发起支付宝支付请求
 *
 *  @param pay_param    支付参数，订单信息
 *  @param successBlock 成功
 *  @param failBlock    失败
 */
- (void)aliPayWithPayParam:(NSString *)pay_param
                   success:(void (^)(PayCode code))successBlock
                   failure:(void (^)(PayCode code,NSString *errorText))failBlock;


/**
 *  回调入口
 *
 *  @param url
 *
 *  @return  value
 */


- (BOOL) handleOpenURL:(NSURL *)url;


@end

NS_ASSUME_NONNULL_END
