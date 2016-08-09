//
//  SGTAFUpload.m
//  SGTFoundation
//
//  Created by 磊吴 on 16/8/3.
//  Copyright © 2016年 block. All rights reserved.
//

#import "SGTAFUpload.h"
#import <AFNetworking.h>
#import "AFNetworkActivityIndicatorManager.h"

@interface SGTAFUpload()

@property (nonatomic, strong) AFURLSessionManager *uploadManager;
@property (nonatomic, strong) NSMutableDictionary *tasks;
@end

@implementation SGTAFUpload

static AFHTTPSessionManager *manager = nil;
+ (AFHTTPSessionManager *)sessionManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 开启转圈圈
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                                diskCapacity:0
                                                                    diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
        
        manager = [[AFHTTPSessionManager alloc]
                   init];
        
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        AFJSONRequestSerializer *headSerializer = [AFJSONRequestSerializer serializer];
        [headSerializer setTimeoutInterval:10];
        
        manager.requestSerializer = headSerializer;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        
//        for (NSString *key in sg_httpHeaders.allKeys) {
//            if (sg_httpHeaders[key] != nil) {
//                [manager.requestSerializer setValue:sg_httpHeaders[key] forHTTPHeaderField:key];
//            }
//        }
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                                  @"text/json",
                                                                                  @"text/plain",
                                                                                  @"text/javascript",
                                                                                  @"text/html"]];
        
        // 设置允许同时最大并发数量，过大容易出问题
        manager.operationQueue.maxConcurrentOperationCount = 5;
    });
    
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uploadManager = [SGTAFUpload sessionManager];
        _tasks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)uploadData:(NSData *)data key:(NSString *)key Url:(NSString *)Url progress:(void (^)(NSProgress *, id<SGTFileUploadProtocol>))progress complete:(SGTUpCompletionHandler)completionHandler option:(NSDictionary *)option {
    NSString *url = [Url copy];
    NSString *imageName = [key copy];
//    if (![_fileManager fileExistsAtPath:imagePath]) {
//        SGTAppLog(@"#error image not exit at %@", imagePath);
//        return nil;
//    }
    NSString *URL = [[NSURL URLWithString:url relativeToURL:[NSURL URLWithString:@"https://yidangpu.com.cn/easypawn-cback/"]] absoluteString];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:URL parameters:option constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:imagePath] name:@"img" fileName:imageName mimeType:@"image/jpeg" error:nil];
        [formData appendPartWithFileData:data name:@"img" fileName:imageName mimeType:@"image/jpeg"];
    } error:nil];
    
    __weak typeof(self) weakself = self;
    NSURLSessionUploadTask *uploadTask = [_uploadManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        __strong typeof(self) strongSelf = weakself;
        if (progress != nil) {
            progress(uploadProgress,strongSelf);
        }
        [strongSelf.tasks removeObjectForKey:key];
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        __strong typeof(self) strongSelf = weakself;
        if (completionHandler != nil) {
            SGTUploadResponse *sgt_response = [SGTUploadResponse responseInforWithAFUploadResult:response responseObj:responseObject error:error];
            completionHandler(sgt_response,key,responseObject);
        }
        [strongSelf.tasks removeObjectForKey:key];
    }];
    [_tasks setObject:uploadTask forKey:key];
}

- (void)uploadFile:(NSString *)filePath key:(NSString *)key Url:(NSString *)Url progress:(void (^)(NSProgress *, id<SGTFileUploadProtocol>))progress complete:(SGTUpCompletionHandler)completionHandler option:(NSDictionary *)option {
    NSString *url = [Url copy];
    NSString *imagePath = [filePath copy];
    NSString *imageName = [key copy];
//    if (![_fileManager fileExistsAtPath:imagePath]) {
//        SGTAppLog(@"#error image not exit at %@", imagePath);
//        return nil;
//    }
    NSString *URL = [[NSURL URLWithString:url relativeToURL:[NSURL URLWithString:@"https://yidangpu.com.cn/easypawn-cback/"]] absoluteString];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:URL parameters:option constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:imagePath] name:@"img" fileName:imageName mimeType:@"image/jpeg" error:nil];
    } error:nil];
    
    __weak typeof(self) weakself = self;
    NSURLSessionUploadTask *uploadTask = [_uploadManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        __strong typeof(self) strongSelf = weakself;
        if (progress != nil) {
            progress(uploadProgress,strongSelf);
        }
        [strongSelf.tasks removeObjectForKey:key];
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        __strong typeof(self) strongSelf = weakself;
        if (completionHandler != nil) {
            SGTUploadResponse *sgt_response = [SGTUploadResponse responseInforWithAFUploadResult:response responseObj:responseObject error:error];
            completionHandler(sgt_response,key,responseObject);
        }
        [strongSelf.tasks removeObjectForKey:key];
    }];
    [_tasks setObject:uploadTask forKey:key];
    [uploadTask resume];
}

- (void)uploadFile:(SGTFileUploadConfig *)uploadConfig progress:(void (^)(NSProgress *, id<SGTFileUploadProtocol>))progress complete:(SGTUpCompletionHandler)completionHandler option:(NSDictionary *)option {
    NSString *url = [uploadConfig.targetUrl copy];
    NSString *filePath = [uploadConfig.filePath copy];
    NSString *fileName = [uploadConfig.fileName copy];
    NSString *mimeType = [uploadConfig.fileMimeType copy];
    NSString *serviceReceiveKey = [uploadConfig.key copy];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if (completionHandler != nil) {
            SGTUploadResponse *sgt_response = [SGTUploadResponse responseInforWithError:@"#error filePath not exit" code:-1];
            completionHandler(sgt_response,fileName,nil);
        }
        return;
    }
    NSString *URL = [[NSURL URLWithString:url relativeToURL:[NSURL URLWithString:@"https://yidangpu.com.cn/easypawn-cback/"]] absoluteString];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:URL parameters:option constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:serviceReceiveKey fileName:fileName mimeType:mimeType error:nil];
    } error:nil];
    
    __weak typeof(self) weakself = self;
    NSURLSessionUploadTask *uploadTask = [_uploadManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        __strong typeof(self) strongSelf = weakself;
        if (progress != nil) {
            progress(uploadProgress,strongSelf);
        }
        [strongSelf.tasks removeObjectForKey:fileName];
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        __strong typeof(self) strongSelf = weakself;
        if (completionHandler != nil) {
            SGTUploadResponse *sgt_response = [SGTUploadResponse responseInforWithAFUploadResult:response responseObj:responseObject error:error];
            completionHandler(sgt_response,fileName,responseObject);
        }
        [strongSelf.tasks removeObjectForKey:fileName];
    }];
    [_tasks setObject:uploadTask forKey:fileName];
    [uploadTask resume];
}
#pragma mark - Getter & Setter

@end
