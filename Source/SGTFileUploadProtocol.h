//
//  SGTFileUploadProtocol.h
//  SGTFoundation
//
//  Created by 磊吴 on 16/8/3.
//  Copyright © 2016年 block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGTUploadResponse.h"
#import "SGTFileUploadConfig.h"

typedef void (^SGTUpCompletionHandler)(SGTUploadResponse *info, NSString *key, NSDictionary *resp);

@protocol SGTFileUploadProtocol <NSObject>

/**
 *    直接上传图片数据
 *
 *    @param data              待上传的数据
 *    @param key               上传到云存储的key
 *    @param params             上传需要的params, 由服务器而定
 *    @param completionHandler 上传完成后的回调函数
 *    @param option            上传时传入的可选参数
 */
- (void)uploadData:(NSData *)data
            key:(NSString *)key
          Url:(NSString *)Url
          progress:(void(^)(NSProgress *progress,id<SGTFileUploadProtocol> uploadObj)) progress
       complete:(SGTUpCompletionHandler)completionHandler
         option:(NSDictionary *)option;

/**
 *    上传图片文件
 *
 *    @param filePath          文件路径
 *    @param key               上传到云存储的key，为nil时表示是由七牛生成
 *    @param params             上传需要的params, 由服务器而定
 *    @param completionHandler 上传完成后的回调函数
 *    @param option            上传时传入的可选参数
 */
- (void)uploadFile:(NSString *)filePath
            key:(NSString *)key
          Url:(NSString *)Url
          progress:(void(^)(NSProgress *progress,id<SGTFileUploadProtocol> uploadObj)) progress
       complete:(SGTUpCompletionHandler)completionHandler
         option:(NSDictionary *)option;

/**
 *  上传文件
 *
 *  @param uploadConfig      文件上传参数
 *  @param progress          上传进度
 *  @param completionHandler 上传结束回调
 *  @param option            上传其他参数
 */
- (void)uploadFile:(SGTFileUploadConfig *)uploadConfig progress:(void(^)(NSProgress *progress,id<SGTFileUploadProtocol> uploadObj)) progress
          complete:(SGTUpCompletionHandler)completionHandler
            option:(NSDictionary *)option;

@end
