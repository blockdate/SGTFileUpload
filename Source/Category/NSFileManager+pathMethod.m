//
//  NSFileManager+pathMethod.m
//  LimitFreeApp
//
//  Created by  江志磊 on 14-8-27.
//  Copyright (c) 2014年  江 志磊. All rights reserved.
//

#import "NSFileManager+pathMethod.h"

@implementation NSFileManager (pathMethod)

+(BOOL)isTimeOutWithPath:(NSString *)path time:(NSTimeInterval)time{
    //    路径不存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        return YES;
    }
    
    if (-1 == time) {
        return NO;
    }
    if (0 == time) {
        return YES;
    }
    
    
    NSDictionary *dic =[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    //NSFileModificationDate 获取文件的修改时间
    NSDate *date =[dic objectForKey:NSFileModificationDate];
    NSDate *currentDate = [NSDate date];
    //算时间差
    NSTimeInterval current= [currentDate timeIntervalSinceDate:date];
    if (current>time) {
        //超时
        return YES;
    }else{
        return NO;
    }
}

+(long long)fileSizeAt:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSLog(@"file not exist at %@",path);
        return 0;
    }
    
    NSDictionary *dic =[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    //NSFileModificationDate 获取文件的修改时间
    NSString *size =[dic objectForKey:NSFileSize];
    return [size longLongValue];

}

@end
