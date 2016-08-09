//
//  SGTFileUploadConfig.h
//  Pods
//
//  Created by 磊吴 on 16/8/4.
//
//

#import <Foundation/Foundation.h>

@interface SGTFileUploadConfig : NSObject

/**
 *  文件名称
 */
@property (nonatomic, copy) NSString *fileName;
/**
 *  文件路径
 */
@property (nonatomic, copy) NSString *filePath;
/**
 *  服务器读取键值
 */
@property (nonatomic, copy) NSString *key;
/**
 *  文件类型
 */
@property (nonatomic, copy) NSString *fileMimeType;
/**
 *  上传地址
 */
@property (nonatomic, copy) NSString *targetUrl;

@end
