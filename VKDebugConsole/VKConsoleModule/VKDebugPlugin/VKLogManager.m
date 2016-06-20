//
//  BDWKLogManager.m
//  Yuedu
//
//  Created by Awhisper on 15/12/28.
//  Copyright © 2015年 baidu.com. All rights reserved.
//

#import "VKLogManager.h"
#import "VKJSONKit.h"

#define VKMAXSTEPRECORD 100
void VKLog(NSString *format, ...){
#ifndef __OPTIMIZE__
    va_list arglist;
    va_start(arglist, format);
    va_end(arglist);
    [VKLogManager VKLogString:format withVarList:arglist];
#endif
}

@interface VKLogManager ()


@end

@implementation VKLogManager

- (instancetype)sharedInstance
{
    return [[self class] singleton];
}

static id __singleton__;
+ (instancetype)singleton
{
    static dispatch_once_t once;
    dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } );
    return __singleton__;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.logDataArray = [[NSMutableArray alloc]init];
    }
    return self;
}

+(void)VKLogString:(NSString *)format withVarList:(va_list)arglist{
#ifndef __OPTIMIZE__
    @synchronized([VKLogManager singleton]) {
        NSString* logstr = [[NSString alloc]initWithFormat:format arguments:arglist];
        logstr = [NSString stringWithFormat:@"NSLog: %@",logstr];
        if (logstr.length > 0) {
            [[VKLogManager singleton].logDataArray addObject:logstr];
            
            if ([[VKLogManager singleton].logDataArray count] > VKMAXSTEPRECORD) {
                NSInteger nowCount = [VKLogManager singleton].logDataArray.count;
                [[VKLogManager singleton].logDataArray removeObjectsInRange:NSMakeRange(0, nowCount - VKMAXSTEPRECORD)];
            }
            if ([NSThread isMainThread]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:VKLogNotification object:logstr];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:VKLogNotification object:logstr];
                });
            }
            
        }
    }
    
#endif
}

+(void)VKLogError:(NSError *)error
{
#ifndef __OPTIMIZE__
    @synchronized([VKLogManager singleton]) {
        
        NSString *userinfo = [error.userInfo VK_JSONString];
        NSString *logstr = [NSString stringWithFormat:@"NSError: domain = %@ code = %@ userinfo = %@",error.domain,@(error.code),userinfo];
        
        if (logstr.length > 0) {
            [[VKLogManager singleton].logDataArray addObject:logstr];
            
            if ([[VKLogManager singleton].logDataArray count] > VKMAXSTEPRECORD) {
                NSInteger nowCount = [VKLogManager singleton].logDataArray.count;
                [[VKLogManager singleton].logDataArray removeObjectsInRange:NSMakeRange(0, nowCount - VKMAXSTEPRECORD)];
            }
            if ([NSThread isMainThread]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:VKLogNotification object:logstr];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:VKLogNotification object:logstr];
                });
            }
            
        }
    }
    
#endif
}

@end