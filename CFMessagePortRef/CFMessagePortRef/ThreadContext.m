//
//  ThreadContext.m
//  NSMachPort
//
//  Created by samuel on 13-11-8.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import "ThreadContext.h"
#import <Foundation/Foundation.h>

@interface ThreadContext()
@property (nonatomic, assign) CFMessagePortRef remotePort;

- (void)checkIn;
- (void)sendMessage:(NSInteger)messageID andData:(CFDataRef)data;
@end

static CFDataRef handle_command(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info)
{
    NSLog(@"--get a message: %d--", (int)msgid);
    
    if (msgid == kCmdAdd)
    {
    #if 1
        int value = 0;
        CFDataGetBytes(data, CFRangeMake(0, CFDataGetLength(data)), (UInt8 *)&value);
        
        value *= value;
        CFDataRef result = CFDataCreate(NULL, (const UInt8 *)&value, sizeof(value));
        ThreadContext *context = (__bridge ThreadContext *)info;
        
        [context sendMessage:kCmdResult andData:result];
    #else //如果执行下面这个耗时操作，那么message会被阻塞在队列里面，直到执行完耗时操作
        static int s_index = 0;
        NSLog(@"start process: %d", ++s_index);
        
        for (NSInteger i = 0; i < 5; i++)
        {
            [NSThread sleepForTimeInterval:1];
            NSLog(@"count: %d", i);
        }
        
        NSLog(@"end process: %d", s_index);
    #endif
    }
    else if (msgid == kCmdExit)
    {
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
    
    return NULL;
}

@implementation ThreadContext

//thread function
//辅助线程，工作是等待发送来的整数，计算开立方，再传回去
//该辅助线程需要一个runloop进行等待
- (void)threadProcess:(id)param
{
    CFStringRef name = (__bridge CFStringRef)param;
    CFMessagePortRef remote = CFMessagePortCreateRemote(NULL, name);
    self.remotePort = remote;
    
    //该name由主线程生成，这里释放
    CFRelease(name);
    
    [self setupLocalPort];
    
    [self checkIn];
    
    CFRunLoopRun();
    
    CFRelease(remote);
    
    NSLog(@"--thread exit--");
}

#pragma mark - Private
- (void)checkIn
{
    CFDataRef data = NULL;
    
    CFStringRef name = CFStringCreateWithFormat(NULL, NULL, CFSTR("net.meandlife.task1"));
    CFIndex len = CFStringGetLength(name);
    
    if (len > 0)
    {
        UInt8 *p = CFAllocatorAllocate(NULL, len, 0);
        if (p)
        {
            CFStringGetBytes(name, CFRangeMake(0, len), kCFStringEncodingASCII, 0, FALSE, p, len, NULL);
            data = CFDataCreate(NULL, p, len);
        }
    }
    
    [self sendMessage:kCmdCheckIn andData:data];
    
    CFRelease(name);
}

- (void)sendMessage:(NSInteger)messageID andData:(CFDataRef)data
{
    CFMessagePortSendRequest(self.remotePort, messageID, data, 0.1, 0.0, NULL, NULL);
}

#pragma mark - NSPortDelegate
- (CFMessagePortRef)setupLocalPort
{
    CFStringRef name = CFStringCreateWithFormat(NULL, NULL, CFSTR("net.meandlife.task1"));
    NSAssert(name != NULL, @"0");
    
    CFMessagePortContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    Boolean shouldFreeInfo;
    
    CFMessagePortRef message = CFMessagePortCreateLocal(NULL, name, handle_command, &context, &shouldFreeInfo);
    NSAssert(message != NULL, @"1");
    
    CFRunLoopSourceRef rlSource = CFMessagePortCreateRunLoopSource(NULL, message, 0);
    NSAssert(rlSource != NULL, @"2");
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rlSource, kCFRunLoopDefaultMode);
    
    CFRelease(name);
    CFRelease(rlSource);
    CFRelease(message);
    
    return message;
}

@end

