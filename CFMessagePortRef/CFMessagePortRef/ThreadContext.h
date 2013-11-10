//
//  ThreadContext.h
//  NSMachPort
//
//  Created by samuel on 13-11-8.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    kCmdAdd = 1,
    kCmdCheckIn,
    kCmdResult,
    kCmdExit,
    kCmdMax
};

@interface ThreadContext : NSObject

//thread function
//param传入主message port的name
//辅助线程，工作是等待发送来的整数，计算平方，再传回去
//该辅助线程需要一个runloop进行等待
- (void)threadProcess:(id)param;

@end
