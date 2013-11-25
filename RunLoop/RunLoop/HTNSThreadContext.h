//
//  HTNSThreadContext.h
//  threadStudy
//
//  Created by samuel on 13-10-26.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTNSThreadContext : NSObject

@property (retain) NSThread *thread;
@property (nonatomic, retain) NSLock *lock;
@property (retain) NSMutableArray *blocks;
@property (assign) CFRunLoopSourceRef runloopSource;
@property (assign) CFRunLoopRef runloop; //线程启动设置

- (void)process:(id)param;

@end
