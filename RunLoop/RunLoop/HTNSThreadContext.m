//
//  HTNSThreadContext.m
//  threadStudy
//
//  Created by samuel on 13-10-26.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import "HTNSThreadContext.h"

@interface HTNSThreadContext()
- (void)addSource:(CFRunLoopSourceRef)source;
@end

@implementation HTNSThreadContext

@synthesize thread;
@synthesize lock;
@synthesize blocks;
@synthesize runloopSource;
@synthesize runloop;

- (void)addSource:(CFRunLoopSourceRef)source
{
    CFRunLoopRef rl = CFRunLoopGetCurrent();
    CFRunLoopAddSource(rl, source, kCFRunLoopDefaultMode);
}

- (void)process:(id)param
{
    self.runloop = CFRunLoopGetCurrent();
    
    //add source
    [self addSource:self.runloopSource];
    
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    NSInteger loopCount = 10;
    do
    {
        NSLog(@"%@ is ready", [[NSThread currentThread] name]);
        //[rl runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
        [rl runUntilDate:[NSDate distantFuture]];
        //[runloop run];
        loopCount--;
        NSLog(@"%@ run: %d", [[NSThread currentThread] name], loopCount);
    }
    while (0/*loopCount*/);
    
    NSLog(@"%@ exit", [[NSThread currentThread] name]);
}

@end
