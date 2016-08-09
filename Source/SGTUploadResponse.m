//
//  SGTUploadResponse.m
//  SGTFoundation
//
//  Created by 磊吴 on 16/8/3.
//  Copyright © 2016年 block. All rights reserved.
//

#import "SGTUploadResponse.h"

const int kSGTZeroDataSize = -6;
const int kSGTInvalidToken = -5;
const int kSGTFileError = -4;
const int kSGTInvalidArgument = -3;
const int kSGTRequestCancelled = -2;
const int kSGTNetworkError = -1;
/**
 https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/index.html#//apple_ref/doc/constant_group/URL_Loading_System_Error_Codes
 
 NSURLErrorUnknown = -1,
 NSURLErrorCancelled = -999,
 NSURLErrorBadURL = -1000,
 NSURLErrorTimedOut = -1001,
 NSURLErrorUnsupportedURL = -1002,
 NSURLErrorCannotFindHost = -1003,
 NSURLErrorCannotConnectToHost = -1004,
 NSURLErrorDataLengthExceedsMaximum = -1103,
 NSURLErrorNetworkConnectionLost = -1005,
 NSURLErrorDNSLookupFailed = -1006,
 NSURLErrorHTTPTooManyRedirects = -1007,
 NSURLErrorResourceUnavailable = -1008,
 NSURLErrorNotConnectedToInternet = -1009,
 NSURLErrorRedirectToNonExistentLocation = -1010,
 NSURLErrorBadServerResponse = -1011,
 NSURLErrorUserCancelledAuthentication = -1012,
 NSURLErrorUserAuthenticationRequired = -1013,
 NSURLErrorZeroByteResource = -1014,
 NSURLErrorCannotDecodeRawData = -1015,
 NSURLErrorCannotDecodeContentData = -1016,
 NSURLErrorCannotParseResponse = -1017,
 NSURLErrorInternationalRoamingOff = -1018,
 NSURLErrorCallIsActive = -1019,
 NSURLErrorDataNotAllowed = -1020,
 NSURLErrorRequestBodyStreamExhausted = -1021,
 NSURLErrorFileDoesNotExist = -1100,
 NSURLErrorFileIsDirectory = -1101,
 NSURLErrorNoPermissionsToReadFile = -1102,
 NSURLErrorSecureConnectionFailed = -1200,
 NSURLErrorServerCertificateHasBadDate = -1201,
 NSURLErrorServerCertificateUntrusted = -1202,
 NSURLErrorServerCertificateHasUnknownRoot = -1203,
 NSURLErrorServerCertificateNotYetValid = -1204,
 NSURLErrorClientCertificateRejected = -1205,
 NSURLErrorClientCertificateRequired = -1206,
 NSURLErrorCannotLoadFromNetwork = -2000,
 NSURLErrorCannotCreateFile = -3000,
 NSURLErrorCannotOpenFile = -3001,
 NSURLErrorCannotCloseFile = -3002,
 NSURLErrorCannotWriteToFile = -3003,
 NSURLErrorCannotRemoveFile = -3004,
 NSURLErrorCannotMoveFile = -3005,
 NSURLErrorDownloadDecodingFailedMidStream = -3006,
 NSURLErrorDownloadDecodingFailedToComplete = -3007
 */
@interface SGTUploadResponse()

@property (nonatomic, copy) NSString *reqId;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, copy) NSString *host;
@property UInt64 timeStamp;

@end
@implementation SGTUploadResponse

static NSString *domain = @"saiz.com";


- (instancetype)initWithCancelled {
    return [self initWithStatus:kSGTRequestCancelled errorDescription:@"cancelled by user"];
}

- (instancetype)initWithStatus:(int)status
                         error:(NSError *)error {
    return [self initWithStatus:status error:error host:nil duration:0];
}

- (instancetype)initWithStatus:(int)status
                         error:(NSError *)error
                          host:(NSString *)host
                      duration:(double)duration {
    if (self = [super init]) {
        _statusCode = status;
        _error = error;
        _host = host;
        _timeStamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (instancetype)init:(int)status withReqId:(NSString *)reqId withHost:(NSString *)host withDuration:(double)duration withBody:(NSData *)body {
    if (self = [super init]) {
        _statusCode = status;
        _reqId = [reqId copy];
        _host = [host copy];
        _timeStamp = [[NSDate date] timeIntervalSince1970];
        if (status != 200) {
            if (body == nil) {
                _error = [[NSError alloc] initWithDomain:domain code:_statusCode userInfo:nil];
            } else {
                NSError *tmp;
                NSDictionary *uInfo = [NSJSONSerialization JSONObjectWithData:body options:NSJSONReadingMutableLeaves error:&tmp];
                if (tmp != nil) {
                    // 出现错误时，如果信息是非UTF8编码会失败，返回nil
                    NSString *str = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
                    if (str == nil) {
                        str = @"";
                    }
                    uInfo = @{ @"error" : str };
                }
                _error = [[NSError alloc] initWithDomain:domain code:_statusCode userInfo:uInfo];
            }
        } else if (body == nil || body.length == 0) {
            NSDictionary *uInfo = @{ @"error" : @"no response json" };
            _error = [[NSError alloc] initWithDomain:domain code:_statusCode userInfo:uInfo];
        }
    }
    return self;
}

- (instancetype)initWithStatus:(int)status
              errorDescription:(NSString *)text {
    NSError *error = [[NSError alloc] initWithDomain:domain code:status userInfo:@{ @"error" : text }];
    return [self initWithStatus:status error:error];
}

+ (instancetype)responseInforWithAFUploadResult:(NSURLResponse *)afresponse responseObj:(id)responseObject error:(NSError *)error {
    SGTUploadResponse *response = [[self alloc] init];
    response.urlResponse = responseObject;
    response.error = error;
    response.timeStamp = [[NSDate date] timeIntervalSince1970];
    response.reqId = [afresponse.URL absoluteString];
    response.host = [afresponse.URL absoluteString];
    return response;
}

+(instancetype)responseInforWithError:(NSString *)error code:(NSInteger)code {
    SGTUploadResponse *response = [[self alloc] init];
    response.error = [[NSError alloc]initWithDomain:error code:code userInfo:nil];
    response.timeStamp = [[NSDate date] timeIntervalSince1970];
    return response;
}
@end
