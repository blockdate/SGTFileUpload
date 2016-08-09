//
//  SGTUploadResponse.h
//  SGTFoundation
//
//  Created by 磊吴 on 16/8/3.
//  Copyright © 2016年 block. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *    中途取消的状态码
 */
extern const int kSGTRequestCancelled;

/**
 *    网络错误状态码
 */
extern const int kSGTNetworkError;

/**
 *    错误参数状态码
 */
extern const int kSGTInvalidArgument;

/**
 *    0 字节文件或数据
 */
extern const int kSGTZeroDataSize;

/**
 *    错误token状态码
 */
extern const int kSGTInvalidToken;

/**
 *    读取文件错误状态码
 */
extern const int kSGTFileError;


@interface SGTUploadResponse : NSObject
/**
 *    状态码
 */
@property (readonly) int statusCode;

@property (nonatomic, copy, readonly) NSString *reqId;
@property (nonatomic, copy, readonly) NSError *error;
@property (nonatomic, copy, readonly) NSString *host;
@property (readonly) UInt64 timeStamp;
@property (nonatomic, strong) NSURLResponse *urlResponse;
/**
 *    是否取消
 */
@property (nonatomic, readonly, getter=isCancelled) BOOL canceled;

/**
 *    成功的请求
 */
@property (nonatomic, readonly, getter=isOK) BOOL ok;

/**
 *    是否网络错误
 */
@property (nonatomic, readonly, getter=isConnectionBroken) BOOL broken;

/**
 *    是否需要重试，内部使用
 */
@property (nonatomic, readonly) BOOL couldRetry;

/**
 *    是否需要换备用server，内部使用
 */
@property (nonatomic, readonly) BOOL needSwitchServer;

+ (instancetype)responseInforWithAFUploadResult:(NSURLResponse *)afresponse responseObj:(id)responseObject error:(NSError *)error;
+ (instancetype)responseInforWithError:(NSString *)error code:(NSInteger)code;
//
///**
// *    工厂函数，内部使用
// *
// *    @return 取消的实例
// */
//+ (instancetype)cancel;
//
///**
// *    工厂函数，内部使用
// *
// *    @param desc 错误参数描述
// *
// *    @return 错误参数实例
// */
//+ (instancetype)responseInfoWithInvalidArgument:(NSString *)desc;
//
///**
// *    工厂函数，内部使用
// *
// *    @param desc 错误token描述
// *
// *    @return 错误token实例
// */
//+ (instancetype)responseInfoWithInvalidToken:(NSString *)desc;
//
///**
// *    工厂函数，内部使用
// *
// *    @param error 错误信息
// *    @param host 服务器域名
// *    @param duration 请求完成时间，单位秒
// *
// *    @return 网络错误实例
// */
//+ (instancetype)responseInfoWithNetError:(NSError *)error
//                                    host:(NSString *)host
//                                duration:(double)duration;
//
///**
// *    工厂函数，内部使用
// *
// *    @param error 错误信息
// *
// *    @return 文件错误实例
// */
//+ (instancetype)responseInfoWithFileError:(NSError *)error;
//
///**
// *    工厂函数，内部使用
// *
// *    @return 文件错误实例
// */
//+ (instancetype)responseInfoOfZeroData:(NSString *)path;

/**
 *    构造函数
 *
 *    @param status 状态码
 *    @param reqId  服务器请求id
 *    @param body   服务器返回内容
 *    @param host   服务器域名
 *    @param duration 请求完成时间，单位秒
 *
 *    @return 实例
 */
- (instancetype)init:(int)status
           withReqId:(NSString *)reqId
            withHost:(NSString *)host
        withDuration:(double)duration
            withBody:(NSData *)body;

@end
