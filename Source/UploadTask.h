//
//  UploadTask.h
//  SGTFoundation
//
//  Created by 磊吴 on 16/1/5.
//  Copyright © 2016年 block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SGTNetworking/SGTNetConfig.h>
@class UploadTask;
@protocol UploadTaskDelegate <NSObject>

- (void)uploadTask:(UploadTask *)task onSuccess:(id) response;
- (void)uploadTask:(UploadTask *)task onfailed:(NSError *) error;

@end

@interface UploadTask : NSObject

/**
 @author block, 16-05-12 15:05:27
 
 @brief 上传结果回调
 */
@property (nonatomic, weak) id<UploadTaskDelegate> delegate;

/**
 @author block, 16-05-12 15:05:38
 
 @brief 上传结束后用于提交服务器的Key，也用于标记唯一上传任务
 */
@property (nonatomic, copy) NSString *key;

/**
 *  上传文件的路径地址
 */
@property (nonatomic, copy) NSString *filePath;
/**
 *  上传至服务器的文件名
 */
@property (nonatomic, copy) NSString *fileName;
/**
 *  文件类型
 */
@property (nonatomic, copy) NSString *mimeType;
/**
 *  上传地址
 */
@property (nonatomic, copy) NSString *url;
/**
 *  上传task的参数
 */
@property (nonatomic, strong) id param;

/**
 *  用于上传的task
 */
@property (nonatomic, strong) NSURLSessionDataTask *task;
//@property (nonatomic, assign) int64_t completedUnitCount;
//@property (nonatomic, assign) int64_t totalUnitCount;

/**
 *  上传进度
 */
@property (nonatomic, strong) NSProgress *progress;

/**
 *  成功回调
 */
@property (nonatomic, copy) SGTResponseSuccess success;
/**
 *  失败回调
 */
@property (nonatomic, copy) SGTResponseFail fail;

/**
 *  失败后重新尝试的总次数
 */
@property (nonatomic, assign) NSInteger retryTime;
/**
 *  已经尝试的次数
 */
@property (nonatomic, assign) NSInteger retryedCount;
/**
 *  是否任然能够重新上传
 */
@property (nonatomic, readonly) BOOL shouldRetry;

#pragma mark 返回属性
@property (nonatomic, copy) id netResponse;

- (instancetype)initWithFilePath:(NSString *)path name:(NSString *)name url:(NSString *)url param:(id)param;
- (instancetype)initWithKey:(NSString *)key FilePath:(NSString *)path name:(NSString *)name url:(NSString *)url param:(id)param;
@end
