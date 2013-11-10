//
//  ViewController.h
//  NSMachPort
//
//  Created by samuel on 13-11-8.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, assign) CFMessagePortRef child;
@property (nonatomic, strong) IBOutlet UILabel *resultLabel;

- (IBAction)buttonHandle:(id)sender;
- (IBAction)exitHandle:(id)sender;

@end
