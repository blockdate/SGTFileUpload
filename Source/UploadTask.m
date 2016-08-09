//
//  UploadTask.m
//  SGTFoundation
//
//  Created by 磊吴 on 16/1/5.
//  Copyright © 2016年 block. All rights reserved.
//

#import "UploadTask.h"

@implementation UploadTask

- (NSString *)description {
    return [NSString stringWithFormat:@"path:%@, restTry:%ld",[_filePath lastPathComponent],_retryTime-_retryedCount];
}

- (instancetype)initWithKey:(NSString *)key FilePath:(NSString *)path name:(NSString *)name url:(NSString *)url param:(id)param {
    self = [self initWithFilePath:path name:[NSString stringWithFormat:@"%@%@",key,name] url:url param:param];
    if (self) {
        _key = key;
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)path name:(NSString *)name url:(NSString *)url param:(id)param {
    self = [super init];
    if (self) {
        _filePath = path;
        _fileName = name;
        _url = url;
        _param = param;
        _retryTime = 3;
        _retryedCount = 0;
    }
    return self;
}

- (BOOL)shouldRetry {
    return _retryTime > _retryedCount;
}

@end
