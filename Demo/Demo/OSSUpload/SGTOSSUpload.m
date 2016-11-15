//
//  SGTOSSUpload.m
//  Pods
//
//  Created by zmj on 16/8/4.
//
//

#import "SGTOSSUpload.h"
#import "SGTUploadResponse.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AliyunOSSiOS/OSSCompat.h>
#ifdef DEBUG
#define SGTAppLog(s, ... ) NSLog( @"[%@：in line: %d]-->[message: %@]", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define SGTAppLog(s, ... )
#endif
NSString * const AccessKey = @"VEyIvKoGCNQ5sUJ9";
NSString * const SecretKey = @"0OF2P03NUNz2SQioD1CjIGQfJ3ohzu";
NSString * const endPoint = @"oss-cn-beijing.aliyuncs.com";
NSString * const multipartUploadKey = @"multipartUploadObject";
OSSClient * client;
NSString * const uploadUrl = @"https://yidangpu.com.cn/easypawn-cback/";
@implementation SGTOSSUpload

- (instancetype)init {
    if (self = [super init]) {
#ifdef DEBUG
    [OSSLog enableLog];
#endif
    [self initOSSClient];
    }
    return self;
}

/**
 *  初始化OSSClient
 */
- (void)initOSSClient{
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AccessKey
                                                                                                            secretKey:SecretKey];
    OSSClientConfiguration * conf = [OSSClientConfiguration new]; // 自行设置
    conf.maxRetryCount = 0; // 网络请求遇到异常失败后的重试次数 0次
    conf.timeoutIntervalForRequest = 30; // 网络请求的超时时间 30秒
    conf.timeoutIntervalForResource = 60; // 允许资源传输的最长时间 60秒
    
    client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential clientConfiguration:conf];
}



- (void)uploadData:(NSData *)data key:(NSString *)key Url:(NSString *)Url progress:(void (^)(NSProgress *, id<SGTFileUploadProtocol>))progress complete:(SGTUpCompletionHandler)completionHandler option:(NSDictionary *)option {
    

}

- (void)uploadFile:(NSString *)filePath key:(NSString *)key Url:(NSString *)Url progress:(void (^)(NSProgress *, id<SGTFileUploadProtocol>))progress complete:(SGTUpCompletionHandler)completionHandler option:(NSDictionary *)option {
    NSString *url = [Url copy];
    NSString *imagePath = [filePath copy];
    NSString *imageName = [key copy];
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    // required fields
    put.bucketName = @"yidang";
    put.objectKey = [@"images" stringByAppendingPathComponent:imageName];
    put.uploadingFileURL = [NSURL fileURLWithPath:imagePath];
    
    // optional fields
    NSProgress *uploadProgress = [NSProgress currentProgress];
    __weak typeof(self) weakself = self;
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        __strong typeof(self) strongSelf = weakself;
        uploadProgress.totalUnitCount = totalBytesExpectedToSend;
        uploadProgress.completedUnitCount = totalByteSent;
        if (progress != nil){
            progress(uploadProgress,strongSelf);
        }
        SGTAppLog(@"当前上传:%lld, 已上传:%lld, 总长度:%lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    put.contentType = @"image/jpeg";
//    put.contentMd5 = @"";
//    put.contentEncoding = @"";
//    put.contentDisposition = @"";
    OSSTask * putTask = [client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        SGTAppLog(@"objectKey: %@", put.objectKey);
        if (!task.error) {
            SGTAppLog(@"upload success!");
            
            if (completionHandler != nil) {
                NSMutableDictionary *responseObject = [NSMutableDictionary dictionary];
                NSMutableDictionary *body = [NSMutableDictionary dictionary];
                [body setObject:[@"http://yidang.oss-cn-beijing.aliyuncs.com/" stringByAppendingString:put.objectKey] forKey:@"imgUrl"];
                NSMutableDictionary *head = [NSMutableDictionary dictionary];
                [head setObject:@(0) forKey:@"errorcode"];
                [head setObject:@"" forKey:@"errormsg"];
                [responseObject setObject:head forKey:@"head"];
                [responseObject setObject:body forKey:@"body"];
                SGTAppLog(@"responseObject------------> %@",responseObject);
                SGTUploadResponse *sgt_response = [SGTUploadResponse responseInforWithAFUploadResult:nil responseObj:responseObject error:nil];
                completionHandler(sgt_response,imageName,responseObject);
            }
        } else {
            NSMutableDictionary *responseObject = [NSMutableDictionary dictionary];
            NSMutableDictionary *body = [NSMutableDictionary dictionary];
            [body setObject:@"" forKey:@"imgUrl"];
            NSMutableDictionary *head = [NSMutableDictionary dictionary];
            [head setObject:[NSNumber numberWithInteger:task.error.code] forKey:@"errorcode"];
            [head setObject:task.error.domain forKey:@"errormsg"];
            [responseObject setObject:head forKey:@"head"];
            [responseObject setObject:body forKey:@"body"];
            SGTAppLog(@"responseObject------------> %@",responseObject);
            SGTUploadResponse *sgt_response = [SGTUploadResponse responseInforWithAFUploadResult:nil responseObj:responseObject error:task.error];
            completionHandler(sgt_response,imageName,responseObject);
        }
        return nil;
    }];
    
}

- (void)uploadFile:(SGTFileUploadConfig *)uploadConfig progress:(void (^)(NSProgress *, id<SGTFileUploadProtocol>))progress complete:(SGTUpCompletionHandler)completionHandler option:(NSDictionary *)option {
    NSString *url = [uploadConfig.targetUrl copy];
    NSString *filePath = [uploadConfig.filePath copy];
    NSString *fileName = [uploadConfig.fileName copy];
    NSString *mimeType = [uploadConfig.fileMimeType copy];
    NSString *serviceReceiveKey = [uploadConfig.key copy];
}

//{
//    "body" : "asd/asda/aaa.png",
//    "head" : {
//        "errorcode" : 0,
//        "errormsg" : "123"
//    }
//}

@end
