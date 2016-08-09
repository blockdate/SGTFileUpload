//
//  SGTFileUploadManager.h
//  SGTFoundation
//
//  Created by 磊吴 on 16/8/3.
//  Copyright © 2016年 block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UploadTask.h"
#import "SGTFileUploadProtocol.h"

@interface SGTFileUploadManager : NSObject

/**
 *  上传进度变更回调
 */
@property (nonatomic, copy) UploadProgressBlock uploadProgressBlock;
/**
 *  上传结束（成功/失败）回调
 */
@property (nonatomic, copy) UploadFinishedBlock uploadFinishBlock;
/**
 *  文件上传的管理器
 */
//@property (nonatomic, strong, readonly) AFURLSessionManager *uploadManager;

/**
 *  用于文件上传的上传工具，默认为SGTAFUpload，可手动指定
 */
@property (nonatomic, strong) id<SGTFileUploadProtocol> fileUploader;

/**
 *  开启上传操作，如果队列中存在失败任务，失败任务将自动加入到待上传任务列表
 */
- (void)start;

/**
 *  重置管理类
 */
- (void)reset;

/**
 *  重新上传失败任务
 */
- (void)retryUpload;

/**
 *  重新上传失败任务
 *
 *  @param finish 结束回调
 */
- (void)retryUploadfinish:(UploadFinishedBlock)finish;

/**
 *  上传进度描述
 *
 *  @return 进度描述 xx%
 */
- (NSString *)uploadProgressDes;

/**
 *  新增上传任务
 *
 *  @param tasks  任务列表
 *  @param finish 结束回调
 */
- (void)addUploadTasks:(NSArray<UploadTask *>*)tasks finish:(UploadFinishedBlock)finish;

/**
 *  新增上传任务
 *
 *  @param tasks 任务列表
 */
- (void)addUploadTasks:(NSArray<UploadTask *>*)tasks;

/*!
 *  @author block, 15-11-15 13:11:45
 *
 *  用于指定网络请求接口的基础url，如：
 *  通常在AppDelegate中启动时就设置一次就可以了。如果接口有来源
 *  于多个服务器，可以调用更新
 *
 *  @param baseUrl 网络接口的基础url
 */
+ (void)updateBaseUrl:(NSString *)baseUrl;

/*!
 *  @author block, 15-11-15 13:11:06
 *
 *  对外公开可获取当前所设置的网络接口基础url
 *
 *  @return 当前基础url
 */
+ (NSString *)baseUrl;

/**
 *  设置上传进度跟新回调
 *
 *  @param block 回调
 */
- (void)setUploadProgressBlock:(UploadProgressBlock)block;

@end
