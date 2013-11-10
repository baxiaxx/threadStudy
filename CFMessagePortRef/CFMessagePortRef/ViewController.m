//
//  ViewController.m
//  NSMachPort
//
//  Created by samuel on 13-11-8.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import "ViewController.h"
#import "ThreadContext.h"

static CFMessagePortRef get_port_from_message_data(CFDataRef data)
{
    CFMessagePortRef port = NULL;
    
    CFIndex len = CFDataGetLength(data);
    if (len > 0)
    {
        UInt8 *p = CFAllocatorAllocate(NULL, len, 0);
        if(p)
        {
            CFDataGetBytes(data, CFRangeMake(0, len), p);
            CFStringRef name = CFStringCreateWithBytes(NULL, p, len, kCFStringEncodingASCII, FALSE);
            
            if (name)
            {
                port = CFMessagePortCreateRemote(NULL, name);
                CFRelease(name);
            }
            
            CFAllocatorDeallocate(NULL, p);
        }
        
    }
    
    return port;
}

static CFDataRef message_handle(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info)
{
    if (msgid == kCmdCheckIn)
    {
        CFMessagePortRef port = get_port_from_message_data(data);
        if (port)
        {
            ViewController *controller = (__bridge ViewController *)info;
            controller.child = port;
        }
    }
    else if (msgid == kCmdResult)
    {
        int value = 0;
        CFDataGetBytes(data, CFRangeMake(0, CFDataGetLength(data)), (UInt8 *)&value);
        
        ViewController *controller = (__bridge ViewController *)info;
        controller.resultLabel.text = [NSString stringWithFormat:@"%d", value];
    }
    
    return NULL;
}

@interface ViewController ()

//创建message port，添加到run loop
- (CFStringRef)setupMessagePort;

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //创建port，并设置
        CFStringRef name = [self setupMessagePort];
        
        //创建线程, 把port的name传入，作为通讯端口
        //传入的name需由子线程释放
        ThreadContext *context = [[ThreadContext alloc] init];
        [NSThread detachNewThreadSelector:@selector(threadProcess:) toTarget:context withObject:(__bridge id)(name)];
    }
    
    return self;
}

- (void)dealloc
{
    if (self.child)
    {
        CFRelease(self.child);
    }
}

- (IBAction)buttonHandle:(id)sender
{
    static NSInteger index = 0;
    
    index++;
    
    CFDataRef data = CFDataCreate(NULL, (const UInt8 *)&index, sizeof(index));
    CFMessagePortSendRequest(self.child, kCmdAdd, data, 0.1, 0, NULL, NULL);
    CFRelease(data);
    
    self.resultLabel.text = @"hello";
}

- (IBAction)exitHandle:(id)sender
{
    CFMessagePortSendRequest(self.child, kCmdExit, NULL, 0.1, 0, NULL, NULL);
}

#pragma mark - Private
- (CFStringRef)setupMessagePort
{
    CFStringRef name = CFStringCreateWithFormat(NULL, NULL, CFSTR("net.meandlife.cfmessageportref"));
    NSAssert(name != NULL, @"0");
    
    CFMessagePortContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    Boolean shouldFreeInfo;
    
    CFMessagePortRef message = CFMessagePortCreateLocal(NULL, name, message_handle, &context, &shouldFreeInfo);
    NSAssert(message != NULL, @"1");
    
    CFRunLoopSourceRef rlSource = CFMessagePortCreateRunLoopSource(NULL, message, 0);
    NSAssert(rlSource != NULL, @"2");
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rlSource, kCFRunLoopDefaultMode);
    
    CFRelease(rlSource);
    CFRelease(message);
    
    return name;
}

@end
