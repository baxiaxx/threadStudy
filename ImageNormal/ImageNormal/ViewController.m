//
//  ViewController.m
//  ImageNormal
//
//  Created by samuel on 13-11-25.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import "ViewController.h"
#import "MyCell.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.layer.borderWidth = 1;
    
	// Do any additional setup after loading the view, typically from a nib.
    CGRect frame = [UIScreen mainScreen].bounds;
    UITableView *table = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    //table.layer.borderWidth = 1;
    //table.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:table];
    self.tableView = table;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCell *cell = (MyCell *)[tableView dequeueReusableCellWithIdentifier:@"ImageNormal"];
    
    if (cell == nil)
    {
        cell = [[MyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ImageNormal"];
    }
    
    NSString *fname = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", indexPath.row + 1] ofType:@"jpg"];
    //注意这里模拟的是网络下载的图片，只能从文件加载，imageWithContentsOfFile没有对图片进行cache，cache需要自己维护
    //另外，这个测试在4S及以上机型不会有卡顿，在iPhone4，以及touch4等配置机型上面有卡顿效果，原理是一样的，用线程来解决滑动的卡顿问题
    //UIImage *image = [UIImage imageNamed:fname];
    
    [cell loadImage:fname];
    
    cell.layer.borderWidth = 1;
    cell.layer.borderColor = [UIColor redColor].CGColor;

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 330.0;
}

@end
