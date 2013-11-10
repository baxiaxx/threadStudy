//
//  ViewController.m
//  NSOperationQueue
//
//  Created by samuel on 13-11-10.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) dispatch_queue_t queue;
- (void)saveImageToFile:(NSArray *)param;
- (UIImage *)imageFromView:(UIView *)view;
@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        dispatch_queue_t q = dispatch_queue_create("myqueue", DISPATCH_QUEUE_SERIAL);
        self.queue = q;
    }
    
    return self;
}

- (void)dealloc
{
    self.queue = nil;
}

- (IBAction)saveHandle:(id)sender
{
    static NSInteger s_index = 0;
    NSString *fname = [NSTemporaryDirectory() stringByAppendingFormat:@"%d.jpg", s_index];
    UIImage *viewImage = [self imageFromView:self.view];
    NSNumber *no = [NSNumber numberWithInt:s_index];
    
    NSMutableArray *param = [[NSMutableArray alloc] initWithObjects:viewImage, fname, no, nil];
    
#if 0 //并发
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self saveImageToFile:param];
    });
#else
    dispatch_async(self.queue, ^{
        [self saveImageToFile:param];
    });
    
#endif
    
    s_index ++;
}

#pragma mark - Private
- (void)saveImageToFile:(NSArray *)param
{
    NSAssert([param count] >= 3, @"0");
    
    UIImage *image = [param objectAtIndex:0];
    NSString *fname = [param objectAtIndex:1];
    NSNumber *no = [param objectAtIndex:2];
    
    NSLog(@"---operation %@ start", no);
    [UIImageJPEGRepresentation(image, 1) writeToFile:fname atomically:YES];
    
    for (NSInteger i = 0; i < 5; i++)
    {
        NSLog(@"operation %@ wait: %d", no, i);
        [NSThread sleepForTimeInterval:1];
    }
    
    NSLog(@"---operation %@ done", no);
}

- (UIImage *)imageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
