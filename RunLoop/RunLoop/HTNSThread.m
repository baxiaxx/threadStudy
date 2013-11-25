//
//  HTDispatch.m
//  threadStudy
//
//  Created by samuel on 13-10-24.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#include <stdio.h>

#import "HTDispatch.h"
#import "HTNSThreadContext.h"

static void ht_runloop_schedule(void *info, CFRunLoopRef rl, CFStringRef mode);
static void ht_runloop_perform(void *info);
static void ht_runloop_cancel(void *info, CFRunLoopRef rl, CFStringRef mode);

void *ht_dispatch_init(void)
{
    HTNSThreadContext *threadContext = [[HTNSThreadContext alloc] init];

    //blocks
    NSMutableArray *array = [[NSMutableArray alloc] init];
    threadContext.blocks = array;
    
    CFAbsoluteTime start, end;
    
    CFRunLoopSourceContext context = {0, (__bridge void *)(threadContext), NULL, NULL, NULL, NULL, NULL,
        &ht_runloop_schedule,
        &ht_runloop_cancel,
        &ht_runloop_perform};
    threadContext.runloopSource = CFRunLoopSourceCreate(NULL, 0, &context);

    start = CFAbsoluteTimeGetCurrent();
    NSThread *thread = [[NSThread alloc] initWithTarget:threadContext selector:@selector(process:) object:threadContext];
    end = CFAbsoluteTimeGetCurrent();
    NSLog(@"--create ns thread: %f", end - start);
    
    [thread setName:@"test thread 1"];
    threadContext.thread = thread;
    
    NSLock *lock = [[NSLock alloc] init];
    threadContext.lock = lock;
    
    start = CFAbsoluteTimeGetCurrent();
    [thread start];
    end = CFAbsoluteTimeGetCurrent();
    NSLog(@"--start ns thread: %f", end - start);
    
    return (__bridge void *)threadContext;
}

void ht_dispatch(void *handle, ht_block block)
{
    if (handle)
    {
        HTNSThreadContext *threadContext = (__bridge HTNSThreadContext *)handle;
        
        NSInteger count;
        //添加bock
        [threadContext.lock lock];
        [threadContext.blocks addObject:block];
        count = [threadContext.blocks count];
        [threadContext.lock unlock];
        
        NSLog(@"add task: %d", count);
        
        CFRunLoopSourceSignal(threadContext.runloopSource);
        CFRunLoopWakeUp(threadContext.runloop);
    }
}

void ht_dispatch_release(void *handle)
{
    if (handle)
    {
        HTNSThreadContext *threadContext = (__bridge HTNSThreadContext *)handle;
        
        NSLog(@"stop run loop");
        
        ht_dispatch(handle, ^{
            NSLog(@"--kill self--");
            CFRunLoopStop(threadContext.runloop);
        });
        
        //CFRunLoopStop(threadContext.runloop);
        
        //[threadContext release];
    }
    //stop runloop -> thread exit
    
}

#pragma mark - Private
static void ht_runloop_schedule(void *info, CFRunLoopRef rl, CFStringRef mode)
{
    NSLog(@"schedual in thread: %@", [[NSThread currentThread] name]);
}

static void ht_runloop_perform(void *info)
{
    if (info)
    {
        HTNSThreadContext *context = (__bridge HTNSThreadContext *)info;
        
        NSLog(@"-----------run source-----------");
        
        while (1)
        {
            [context.lock lock];
            if ([context.blocks count] > 0)
            {
                NSLog(@"block coun: %d", [context.blocks count]);
                ht_block block = [context.blocks objectAtIndex:0];
                [context.blocks removeObjectAtIndex:0];
                [context.lock unlock];
                
                (block)();
            }
            else
            {
                [context.lock unlock];
                break;
            }
        }
    }
}

static void ht_runloop_cancel(void *info, CFRunLoopRef rl, CFStringRef mode)
{
    NSLog(@"cancel in thread: %@", [[NSThread currentThread] name]);
}
