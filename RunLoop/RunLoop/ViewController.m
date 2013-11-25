//
//  ViewController.m
//  threadStudy
//
//  Created by samuel on 13-10-20.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "HTDispatch.h"

@interface ViewController ()
@property (nonatomic, assign) void *dispatchHandle;
@end

@implementation ViewController

@synthesize dispatchHandle;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        void *handle = ht_dispatch_init();
        self.dispatchHandle = handle;
    }
    
    return self;
}

- (void)sendCmd
{
    if (self.dispatchHandle)
    {
        static int s_index = 0;
        ht_dispatch(self.dispatchHandle, ^{
            NSLog(@"start process: %d", ++s_index);
            
            for (NSInteger i = 0; i < 5; i++)
            {
                [NSThread sleepForTimeInterval:1];
                NSLog(@"count: %d", i);
            }
            
            NSLog(@"end process: %d", s_index);
        });
    }
}

- (void)stopDispatch
{
    ht_dispatch_release(self.dispatchHandle);
    self.dispatchHandle = NULL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(100, 200, 100, 44);
    [button setTitle:@"发送" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sendCmd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    UIButton *stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    stopButton.frame = CGRectMake(100, 280, 100, 44);
    [stopButton setTitle:@"停止" forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stopDispatch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopButton];
    
    self.view.backgroundColor = [UIColor orangeColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
