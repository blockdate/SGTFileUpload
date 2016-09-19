//
//  SGTAFUpload.h
//  SGTFoundation
//  文件上传工具单元类
//  此上传功能使用AFNetworking实现，如果需要使用七牛或OSS等上传服务，实现SGTFileUploadProtocol即可
//  Created by 磊吴 on 16/8/3.
//  Copyright © 2016年 block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGTFileUploadProtocol.h"

@interface SGTAFUpload : NSObject <SGTFileUploadProtocol>

@end
