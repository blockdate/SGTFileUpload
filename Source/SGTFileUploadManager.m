//
//  SGTFileUploadManager.m
//  SGTFoundation
//
//  Created by 磊吴 on 16/8/3.
//  Copyright © 2016年 block. All rights reserved.
//

#import "SGTFileUploadManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "NSFileManager+pathMethod.h"
#import "SGTAFUpload.h"
#ifdef DEBUG
#define SGTAppLog(s, ... ) NSLog( @"[%@：in line: %d]-->[message: %@]", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define SGTAppLog(s, ... )
#endif

static NSString *sg_privateNetworkBaseUrl = nil;
//static BOOL sg_isEnableInterfaceDebug = NO;

//static BOOL sg_shouldAutoEncode = YES;
static NSDictionary *sg_httpHeaders = nil;

@interface SGTFileUploadManager()


@property (nonatomic, strong) NSMutableArray<UploadTask *> *waitingUploadTasks;
@property (nonatomic, strong) NSMutableArray<UploadTask *> *executingUploadTasks;
@property (nonatomic, strong) NSMutableArray<UploadTask *> *finishedUploadTasks;
@property (nonatomic, strong) NSMutableArray<UploadTask *> *failedUploadTasks;
@property (nonatomic, strong) NSMutableArray<UploadTask *> *retryUploadTasks;
@property (nonatomic, strong) NSMutableArray<UploadTask *> *repeatUploadTasks;

@property (nonatomic, strong) NSMutableDictionary *uploadTasksMap;
@property (nonatomic, strong) NSMutableDictionary *uploadTaskArrayMap;

@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, strong) NSProgress *uploadProgress;

//@property (nonatomic, strong) AFURLSessionManager *uploadManager;

@property (nonatomic, strong) dispatch_queue_t imageUploadProgressDealQueue;

@end

@implementation SGTFileUploadManager

#pragma mark - Class method
+ (void)updateBaseUrl:(NSString *)baseUrl {
    sg_privateNetworkBaseUrl = baseUrl;
}

+ (NSString *)baseUrl {
    return sg_privateNetworkBaseUrl;
}

#pragma mark - Init Method & Life Cycle

+(instancetype)manager {
    return [self new];
}



- (instancetype)init{
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];
        _waitingUploadTasks = [NSMutableArray array];
        _executingUploadTasks = [NSMutableArray array];
        _finishedUploadTasks = [NSMutableArray array];
        _failedUploadTasks = [NSMutableArray array];
        _retryUploadTasks = [NSMutableArray array];
        _repeatUploadTasks = [NSMutableArray array];
        _uploadTasksMap = [NSMutableDictionary dictionary];
        _uploadTaskArrayMap = [NSMutableDictionary dictionary];
//        _uploadManager = [SGTFileUploadManager sessionManager];
//        _uploadManager.responseSerializer = [AFJSONResponseSerializer serializer];
//        _uploadManager.operationQueue.maxConcurrentOperationCount = 3;
        self.imageUploadProgressDealQueue = dispatch_queue_create("imageUploadProgressDealQueue", NULL);
        
    }
    return self;
}

- (void)dealloc{
    SGTAppLog(@"%s",__FUNCTION__);
}

#pragma mark - Upload Method
- (void)start {
    if (self.fileUploader == nil) {
        self.fileUploader = [[SGTAFUpload alloc]init];
        SGTAppLog(@"file uploader was not initialize");
    }
    
    if (self.failedUploadTasks.count > 0) {
        [self retryUpload];
    }else {
        [self update];
    }
    
    
}

- (void)reset {
    _uploadTasksMap = [NSMutableDictionary dictionary];
    _uploadTaskArrayMap = [NSMutableDictionary dictionary];
    _waitingUploadTasks = [NSMutableArray array];
    _executingUploadTasks = [NSMutableArray array];
    _finishedUploadTasks = [NSMutableArray array];
    _failedUploadTasks = [NSMutableArray array];
    _retryUploadTasks = [NSMutableArray array];
    _repeatUploadTasks = [NSMutableArray array];
    self.uploadProgress = nil;
}

- (void)retryUpload {
    if (self.fileUploader == nil) {
        self.fileUploader = [[SGTAFUpload alloc]init];
        SGTAppLog(@"file uploader was not initialize");
    }
    
    if(self.waitingUploadTasks.count > 0) {
        SGTAppLog(@"上传等待队列不为空,无法重新上传");
        return;
    }
    if (self.executingUploadTasks.count > 0) {
        SGTAppLog(@"上传队列不为空,无法重新上传");
        return;
    }
    
    for (UploadTask *task in self.failedUploadTasks) {
        task.retryedCount = 0;
    }
    [self.waitingUploadTasks addObjectsFromArray:self.failedUploadTasks];
    [self.failedUploadTasks removeAllObjects];
    
    [self update];
}

- (void)retryUploadfinish:(UploadFinishedBlock)finish {
    self.uploadFinishBlock = finish;
    [self retryUpload];
}

- (void)addUploadTasks:(NSArray<UploadTask *>*)tasks finish:(UploadFinishedBlock)finish{
    SGTAppLog(@"开始上传");
    self.uploadFinishBlock = finish;
    self.uploadProgress = [NSProgress progressWithTotalUnitCount:100*tasks.count];
    
    [self.waitingUploadTasks addObjectsFromArray:tasks];
    for (UploadTask *task in self.waitingUploadTasks) {
        
        long long size = [NSFileManager fileSizeAt:task.filePath];
        task.progress = [NSProgress progressWithTotalUnitCount:size];
        [self.uploadTasksMap setObject:task forKey:task.fileName];
    }
//    [self update];
}

- (void)addUploadTasks:(NSArray<UploadTask *>*)tasks {
    [self addUploadTasks:tasks finish:nil];
}

- (void)update {
    SGTAppLog(@"已成功：%ld--进行中：%ld--等待：%ld--错误%ld--重试：%ld",_finishedUploadTasks.count,_executingUploadTasks.count,_waitingUploadTasks.count,_failedUploadTasks.count,_retryUploadTasks.count);
    
    if (self.waitingUploadTasks.count >= 1 ) {
        //等待队列中存在未完成任务
        UploadTask *task = self.waitingUploadTasks.firstObject;
        [self startUploadTask:task];
    }else {
        if (self.retryUploadTasks.count >= 1) {
            //重试队列中存在未完成任务
            UploadTask *task = self.retryUploadTasks.firstObject;
            [self retryUploadTask:task];
        }else {
            if(self.failedUploadTasks.count>0 && self.executingUploadTasks.count <= 0) {
                //等待/重试/执行队列任务为空,失败队列中任务数超过1,当前状态定性为上传失败
                if (self.uploadFinishBlock) {
                    NSString *count = [NSString stringWithFormat:@"%ld",self.failedUploadTasks.count];
                    NSArray *task = self.failedUploadTasks;
                    NSError *err= [NSError errorWithDomain:@"图片上传失败，请稍后再试" code:401 userInfo:@{@"count":count,@"tasks":task}];
                    self.uploadFinishBlock(self.uploadProgress, err);
                }
            }else if(self.failedUploadTasks.count <= 0 && self.executingUploadTasks.count <=0){
                //等待/重试/执行/失败队列任务为空,当前状态定性为上传完成
                if (self.uploadFinishBlock) {
                    self.uploadFinishBlock(self.uploadProgress, nil);
                }
            }
        }
    }
}

- (void)retryUploadTask:(UploadTask *)task {
    [self.retryUploadTasks removeObject:task];
    [self.executingUploadTasks addObject:task];
    task.retryedCount ++;
    [self uploadTask:task];
    //    [self uploadImage:task.url imagePath:task.filePath name:task.fileName params:task.param success:task.success fail:task.fail];
}

- (void)startUploadTask:(UploadTask *)task {
    [self.waitingUploadTasks removeObject:task];
    [self.executingUploadTasks addObject:task];
    [self uploadTask:task];
    //    [self uploadImage:task.url imagePath:task.filePath name:task.fileName params:task.param success:task.success fail:task.fail];
}
- (void)uploadTask:(UploadTask *)task {
    NSString *url = task.url;
    NSString *imagePath = task.filePath;
    NSString *imageName = task.fileName;
    id params = task.param;
    
    if (![_fileManager fileExistsAtPath:imagePath]) {
        SGTAppLog(@"#error image not exit at %@", imagePath);
        return ;
    }
    __weak typeof(self) weakself = self;
    [self.fileUploader uploadFile:imagePath key:imageName Url:url progress:^(NSProgress *progress, id<SGTFileUploadProtocol> uploadObj) {
        __strong typeof(self) strongSelf = weakself;
        if (strongSelf == nil) {
            return;
        }
        UploadTask *task = [strongSelf.uploadTasksMap objectForKey:imageName];
        [strongSelf setUploadProgressCompletedUnitCountWithOldProgress:task.progress newProgress:progress];
        SGTAppLog(@"progress:%lld,%lld,%f",strongSelf.uploadProgress.completedUnitCount,strongSelf.uploadProgress.totalUnitCount,strongSelf.uploadProgress.fractionCompleted);
    } complete:^(SGTUploadResponse *info, NSString *key, NSDictionary *resp) {
        __strong typeof(self) strongSelf = weakself;
        UploadTask *task = [strongSelf.uploadTasksMap objectForKey:key];
        if (info.error == nil) {
            [strongSelf taskUploadComplete:task response:info];
        }else {
            [strongSelf taskUploadFailed:task error:info.error];
        }
    } option:params];
    
}

- (void)taskUploadComplete:(UploadTask *)task response:(SGTUploadResponse *)response {
//    UploadTask *task = [strongSelf.uploadTasksMap objectForKey:imageName];
    task.netResponse = response.urlResponse;
    [self.finishedUploadTasks addObject:task];
    [self.executingUploadTasks removeObject:task];
    if (task.success != nil) {
        task.success(response.urlResponse);
    }
    if (task.delegate != nil && [task.delegate respondsToSelector:@selector(uploadTask:onSuccess:)]) {
        [task.delegate uploadTask:task onSuccess:nil];
    }
    SGTAppLog(@"上传成功 :%@",task);
    [self update];
}

- (void)taskUploadFailed:(UploadTask *)task error:(NSError *)error {
//    UploadTask *task = [strongSelf.uploadTasksMap objectForKey:imageName];
    task.progress.completedUnitCount = 0;
    if (task.shouldRetry) {
        [self.retryUploadTasks addObject:task];
    }else {
        [self.failedUploadTasks addObject:task];
    }
    [self.executingUploadTasks removeObject:task];
    if(task.fail != nil) {
        task.fail(error);
    }
    if (task.delegate != nil && [task.delegate respondsToSelector:@selector(uploadTask:onfailed:)]) {
        [task.delegate uploadTask:task onfailed:error];
    }
    SGTAppLog(@"上传失败 :%@\n%@",task, error.domain);
    [self update];
}

//- (SGTRequestOperation *)uploadTask:(UploadTask *)task {
//    NSString *url = task.url;
//    NSString *imagePath = task.filePath;
//    NSString *imageName = task.fileName;
//    id params = task.param;
//    
//    if (![_fileManager fileExistsAtPath:imagePath]) {
//        SGTAppLog(@"#error image not exit at %@", imagePath);
//        return nil;
//    }
//    
//    NSString *URL = [[NSURL URLWithString:url relativeToURL:[NSURL URLWithString:sg_privateNetworkBaseUrl]] absoluteString];
//    
//    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:URL parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:imagePath] name:@"img" fileName:imageName mimeType:@"image/jpeg" error:nil];
//    } error:nil];
//    __weak typeof(self) weakself = self;
//    NSURLSessionUploadTask *uploadTask = [_uploadManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
//        __strong typeof(self) strongSelf = weakself;
//        if (strongSelf == nil) {
//            return;
//        }
//        UploadTask *task = [strongSelf.uploadTasksMap objectForKey:imageName];
//        [self setUploadProgressCompletedUnitCountWithOldProgress:task.progress newProgress:uploadProgress];
//        SGTAppLog(@"progress:%lld,%lld,%f",strongSelf.uploadProgress.completedUnitCount,strongSelf.uploadProgress.totalUnitCount,strongSelf.uploadProgress.fractionCompleted);
//        
//    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        __strong typeof(self) strongSelf = weakself;
//        if (strongSelf == nil) {
//            return;
//        }
//        if (error) {
//            
////            if ([SGTNetworking isDebug]) {
////                [SGTNetworking logWithFailError:error url:URL params:params];
////            }
//            UploadTask *task = [strongSelf.uploadTasksMap objectForKey:imageName];
//            task.progress.completedUnitCount = 0;
//            if (task.shouldRetry) {
//                [strongSelf.retryUploadTasks addObject:task];
//            }else {
//                [strongSelf.failedUploadTasks addObject:task];
//            }
//            [strongSelf.executingUploadTasks removeObject:task];
//            if(task.fail != nil) {
//                task.fail(error);
//            }
//            if (task.delegate != nil && [task.delegate respondsToSelector:@selector(uploadTask:onfailed:)]) {
//                [task.delegate uploadTask:task onfailed:error];
//            }
//            SGTAppLog(@"上传失败 :%@\n%@",task, error.domain);
//        } else {
//            
////            if ([SGTNetworking isDebug]) {
////                [SGTNetworking logWithSuccessResponse:responseObject url:URL params:nil];
////            }
//            UploadTask *task = [strongSelf.uploadTasksMap objectForKey:imageName];
//            task.netResponse = responseObject;
//            [strongSelf.finishedUploadTasks addObject:task];
//            [strongSelf.executingUploadTasks removeObject:task];
//            if (task.success != nil) {
//                task.success(responseObject);
//            }
//            if (task.delegate != nil && [task.delegate respondsToSelector:@selector(uploadTask:onSuccess:)]) {
//                [task.delegate uploadTask:task onSuccess:error];
//            }
//            SGTAppLog(@"上传成功 :%@",task);
//        }
//        [strongSelf update];
//    }];
//    
//    [uploadTask resume];
//    return uploadTask;
//    
//}

-(NSString *)uploadProgressDes {
    NSInteger totalcount = self.uploadTasksMap.count;
    NSInteger finish = self.finishedUploadTasks.count;
    
    return [NSString stringWithFormat:@"%ld/%ld",finish,totalcount];
}

- (void)setUploadProgressCompletedUnitCountWithOldProgress:(NSProgress*)oldProgress newProgress:(NSProgress*)newProgress {
    typeof(self) weakSelf = self;
    dispatch_sync(self.imageUploadProgressDealQueue, ^{
        NSInteger oldP = oldProgress.completedUnitCount * 100.0 / oldProgress.totalUnitCount;
        NSInteger newP = newProgress.completedUnitCount * 100.0 / newProgress.totalUnitCount;
        weakSelf.uploadProgress.completedUnitCount -= oldP;
        weakSelf.uploadProgress.completedUnitCount += newP;
        oldProgress.completedUnitCount = newProgress.completedUnitCount;
        oldProgress.totalUnitCount = newProgress.totalUnitCount;
    });
    
}

#pragma mark - Getter & Setter

- (void)setUploadProgressBlock:(UploadProgressBlock)block{
    _uploadProgressBlock = block;
}

@end
